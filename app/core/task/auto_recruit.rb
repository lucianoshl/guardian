class Task::AutoRecruit < Task::Abstract

  performs_to 1.hour

  def run
    dates = []

    Village.my.map do |village|
      if (!village.model.nil?)
        recruit(village)
        dates << build(village)
      end
    end

    dates.compact.sort{|a,b| a <=> b}.first
    binding.pry
  end

  def recruit village

    train_time = self.class._performs_to
    train_until = Time.zone.now + train_time

    train_screen = Screen::Train.new(village: village.vid)

    half_storage = (train_screen.storage_size * 0.5).ceil

    limit_resources = Resource.new(wood: half_storage, stone: half_storage, iron: half_storage)

    complete_units = {}
    train_screen.production_units.values.map{|a| complete_units.merge!(a)}
    complete_units = Troop.new(train_screen.total_units) + Troop.new(complete_units)

    train_config = village.model.troops

    to_train = (train_config - complete_units).remove_negative

    target_buildings = train_screen.release_time.to_a.select{|a| a[1] < train_until }.map(&:first)

    to_train_in_time = Troop.new

    target_buildings.map do |building|
      seconds_to_train = train_until - train_screen.release_time[building]
      building_to_train = to_train.from_building(building)
      building_to_train.to_h.map do |unit,qte|
        next if (train_screen.train_info[unit].nil?)
        train_seconds = train_screen.train_info[unit]["build_time"]
        while (seconds_to_train > 0 && qte > 0) 
          to_train_in_time[unit] += 1
          seconds_to_train -= train_seconds
          qte -= 1
        end
      end
    end

    train_times = {}
    target_buildings.map {|a| train_times[a] = 0}

    if (!two_itens_in_build_queue?(village))
      resources = train_screen.resources - limit_resources
    else
      resources = train_screen.resources
    end

    return if (resources.has_negative?)

    real_train = Troop.new
    to_train_in_time = to_train_in_time.to_h

    loop do 
      Rails.logger.info("Test recruit #{real_train.to_h}")
      enter = false
      to_train_in_time.map do |unit,qte|
        next if (train_screen.train_info[unit].nil?)

        building,current_time = train_times.to_a.min {|a,b| a[1] <=> b[1]}
        cost = train_screen.train_info[unit].to_resource
        if (qte > 0 && Troop.from_building?(building,unit) && resources.include?(cost))
          build_time = train_screen.train_info[unit]["build_time"]
          to_train_in_time[unit] -= 1
          real_train[unit] += 1
          train_times[building] += build_time
          resources -= cost
          enter = true
        end
      end
      break if (!enter)
    end

    train_screen.train(real_train)
    return nil
  end

  def two_itens_in_build_queue?(village)
    main_screen = Screen::Main.new(id: village.vid)
    main_screen.queue.size >= 2
  end

  def build village
    main_screen = Screen::Main.new(id: village.vid)
    config = village.model.buildings
    return if (main_screen.queue.size >= 2)

    current = Model::Buildings.new(main_screen.buildings.map{|k,v| [k,v.level]}.to_h)

    remaining = (config - current).remove_negative

    to_build = (remaining.attributes.select{|k,v| v > 0 }.map do |k,v|
      next if main_screen.buildings_metadata[k].nil?

      item = OpenStruct.new
      item.name = k
      item.current_level = current[k]
      item.next_level = item.current_level + 1
      item.cost = main_screen.buildings_metadata[k].cost(item.next_level)
      item.remaining_resources_if_build = (main_screen.resources - item.cost).total
      item 
    end).compact

    target = to_build.sort{|b,a| a.remaining_resources_if_build <=> b.remaining_resources_if_build }.first

    return if !main_screen.resources.include?(target.cost)

    build_time = main_screen.build(target.name)

    if (main_screen.queue.size < 2)
      next_execute = Time.zone.now
    else
      next_execute = build_time
    end

    if (next_execute <= (Time.zone.now + self.class._performs_to))
      return next_execute
    end

    return nil

  end

end
