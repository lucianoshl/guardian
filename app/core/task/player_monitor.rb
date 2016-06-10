class Task::PlayerMonitor < Task::Abstract

  performs_to 1.hour

  def run
    my_village = Screen::Overview.new.villages.first
    targets = Screen::Map.neighborhood(my_village,10).villages.flatten.uniq

    saved = Village.in(vid: targets.map(&:vid)).to_a.map{|v| [v.vid,v] }.to_h

    targets = targets.select do |a|
      my_village.distance(a) <= 10
    end

    targets = targets.map do |item|
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

end