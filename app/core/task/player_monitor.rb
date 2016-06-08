class Task::PlayerMonitor < Task::Abstract

  performs_to 1.hour

  def run
    my_village = Screen::Overview.new.villages.first
    targets = Screen::Map.neighborhood(my_village,10).villages.flatten.uniq

    saved = Village.in(vid: targets.map(&:vid)).to_a.map{|v| [v.vid,v] }.to_h

    targets = targets.map do |item|
      village = saved[item.vid] || Village.new
      village.vid = item.vid
      village.x = item.x
      village.y = item.y
      village.name = item.name
      village.points = item.points
      village
    end

    targets = targets.sort do |a,b|
      a.distance(my_village) <=> b.distance(my_village)
    end

    targets = targets.select do |a|
      a.distance(my_village) <= 10
    end

    targets.map(&:upsert)
  end

end