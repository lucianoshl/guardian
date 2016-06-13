class Task::PlayerMonitor < Task::Abstract

  performs_to 1.hour
  
  sleep? false

  def run
    my_village = Screen::Overview.new.villages.first
    targets = Screen::Map.neighborhood(my_village,10).villages.flatten.uniq

    saved = Village.in(vid: targets.map(&:vid)).to_a.map{|v| [v.vid,v] }.to_h

    save_allies(targets)
    save_players(targets)

    targets = targets.select do |a|
      my_village.distance(a) <= 10
    end

    targets = targets.pmap do |item|
      village = saved[item.vid] || Village.new
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
      village.player = item.player.nil? ? nil : Player.where(pid: item.player.pid).first
      village
    end

    targets = targets.sort do |a,b|
      a.distance(my_village) <=> b.distance(my_village)
    end

    targets.map(&:save)
  end

  def register_point_modification village,item
    difference = village.points.nil? ? 0 : village.points - item.points 
    village.points_history << { date: Time.zone.now, points: item.points, difference: difference }
  end

  def save_players targets
    all = targets.map(&:player).compact.uniq{|a| a.pid }

    saved = Player.in(pid: all.map(&:pid)).to_a.map{|v| [v.pid,v] }.to_h

    players = all.pmap do |item|
      player = saved[item.pid] || Player.new
      player.pid = item.pid
      player.name = item.name
      player.points = item.points
      player.ally = item.ally.nil? ? nil : Ally.where(aid: item.ally.aid).first 
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
  end

end