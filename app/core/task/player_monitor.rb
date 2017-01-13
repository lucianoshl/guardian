class Task::PlayerMonitor < Task::Abstract

  performs_to 1.hour
  
  sleep? false 

  def save_my_villages
    player_screen = Screen::InfoPlayer.new(id: User.first.player.pid)

    my_villages = player_screen.villages.map do |id| 
      Screen::InfoVillage.new(id: id).village
    end

    merge(my_villages)
    
    return Village.my.all
  end

  def merge(villages)
      saved = Village.in(vid: villages.map(&:vid)).to_a.map{|v| [v.vid,v] }.to_h

      villages.map do |village|
        merge_one(village,saved[village.vid]).save
      end
  end

  def merge_one(extracted,saved)
    village = saved || Village.new
    village.vid = extracted.vid
    village.x = extracted.x
    village.y = extracted.y
    village.name = extracted.name
    village.points = extracted.points 
    village.player = @players[extracted.player_id]
    return village
  end

  def run
    Rails.logger.info("PlayerMonitor start")

    @allies = [] # cache after
    @players = Player.all.to_a.map { |p| [p.pid,p] }.to_h

    my_villages = save_my_villages

    distance = Config.pillager.distance(10)  
    targets = Screen::Map.neighborhood(my_villages,distance).villages.flatten.uniq

    saved = Village.in(vid: targets.map(&:vid)).to_a.map{|v| [v.vid,v] }.to_h

    Rails.logger.info("Saving allies and players start")
    @allies = save_allies(targets)
    save_players(targets)
    @players = Player.all.to_a.map { |p| [p.pid,p] }.to_h
    Rails.logger.info("Saving allies and players end")

    Rails.logger.info("Merging new information with saved villages start")
    # targets_to_save = (targets.map do |item|
    targets_to_save = (Parallel.map(targets, { progress: "Merging", in_threads: 3 }) do |item|

      village = merge_one(item,saved[item.vid])
      database_village = nil
      if (!saved[item.vid].nil?)
        database_village = saved[item.vid].clone.attributes.clone
        database_village.delete('next_event')
        database_village.delete('_id')
      end

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
    
    Rails.logger.info("Saving #{targets_to_save.size} villages")
    targets_to_save.each_with_index.to_a.pmap do |target,i|
      puts "#{i+1}/#{targets_to_save.size}"
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

  def save_players targets
    all = targets.map(&:player).compact.uniq{|a| a.pid }

    players = all.pmap do |item|
      player = @players[item.pid] || Player.new
      player.pid = item.pid
      player.name = item.name
      player.points = item.points
      player.ally = item.ally.nil? ? nil : @allies[item.ally.aid]
      player
    end
    players.pmap(&:save)
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