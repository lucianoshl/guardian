class Task::PlayerMonitor < Task::Abstract

  performs_to 1.hour
  
  sleep? false 

  def run(itens=nil)
    Rails.logger.info("PlayerMonitor start")

    my_villages = itens

    player = User.first.player
    if (!player.nil?)
      player_screen = Screen::InfoPlayer.new(id: player.pid)

      my_villages = player_screen.villages.map do |id| 
        Screen::InfoVillage.new(id: id).village
      end
    else 
      my_villages = Village.my.all.to_a
    end

    distance = Config.pillager.distance(10) 
    targets = Screen::Map.neighborhood(my_villages,distance).villages.flatten.uniq

    saved = Village.in(vid: targets.map(&:vid)).to_a.map{|v| [v.vid,v] }.to_h

    Rails.logger.info("Saving allies and players start")
    allies = save_allies(targets)
    players = save_players(targets,allies)
    Rails.logger.info("Saving allies and players end")

    pair = targets.map do |target|
      distances = my_villages.map do |village|
        {target: target, origin: village, distance: village.distance(target)}
      end
      distances.sort{|a,b| a[:distance]<=>b[:distance]}.first
    end

    targets = pair.sort{|a,b| a[:distance]<=>b[:distance]}.map {|a| a[:target]}

    Village.not_in(vid: targets.map(&:vid)).delete_all

    Rails.logger.info("Merging new information with saved villages start")
    targets = (targets.pmap do |item|
      village = saved[item.vid] || Village.new
      database_village = village.clone
      village.vid = item.vid
      village.x = item.x
      village.y = item.y
      village.name = item.name
      village.points_history ||= []
      if (village.points_history.map{|a| a[:points] }.last != item.points)
        register_point_modification(village,item)
      end
      village.points = item.points
      village.is_barbarian = item.player_id.nil?
      village.player = item.player.nil? ? nil : players[item.player.pid]
      
      database_village = database_village.attributes.clone
      database_village.delete('next_event')
      database_village.delete('_id')

      village_attr = village.attributes.clone
      village_attr.delete('next_event')
      village_attr.delete('_id') 

      if (village_attr == database_village)
        nil
      else        
        village
      end
    end).compact
    Rails.logger.info("Merging new information with saved villages end")

    Rails.logger.info("Saving #{targets.size} villages")
    targets.each_with_index.to_a.pmap do |target,i|
      puts "#{i+1}/#{targets.size}"
      target.save
    end
    Rails.logger.info("Villages saved!")

    puts("PlayerMonitor end")
    return nil
  end

  def register_point_modification village,item
    difference = village.points.nil? ? 0 : item.points - village.points
    village.points_history << { date: Time.zone.now, points: item.points, difference: difference }
  end

  def save_players targets,allies
    all = targets.map(&:player).compact.uniq{|a| a.pid }

    saved = Player.in(pid: all.map(&:pid)).to_a.map{|v| [v.pid,v] }.to_h

    players = all.pmap do |item|
      player = saved[item.pid] || Player.new
      player.pid = item.pid
      player.name = item.name
      player.points = item.points
      player.ally = item.ally.nil? ? nil : allies[item.ally.aid]
      player
    end
    players.pmap(&:save)
    players.map{|p| [p.pid,p] }.to_h
  end

  def save_allies targets
    all = targets.map(&:player).compact.map(&:ally).compact.uniq{|a| a.aid }

    saved = Ally.in(aid: all.map(&:aid)).to_a.map{|v| [v.aid,v] }.to_h

    allies = all.pmap do |item|
      ally = saved[item.aid] || Ally.new
      ally.aid = item.aid
      ally.name = item.name
      ally.points = item.points
      ally
    end
    allies.pmap(&:save)

    allies.map{|a| [a.aid,a] }.to_h
  end

end