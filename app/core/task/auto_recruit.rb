class Task::AutoRecruit < Task::Abstract

  performs_to 1.hour

  def run
    dates = []
    Village.my.map do |village|
      if (!village.model.nil? && village.disable_auto_recruit != true)
        recruit(village)
        dates << build(village)
        coins(village)
      end
    end

    dates.flatten.compact.sort{|a,b| a <=> b}.first
  end

  def coins(village)
    snob_screen = Screen::Snob.new(village: village.vid)
    if (snob_screen.possible_coins > 0)
      snob_screen.do_coin(snob_screen.possible_coins)
    end
  end

  def calculate_units_to_train(train_screen,village)
    to_train = (village.model.troops - train_screen.complete_units).remove_negative
    return to_train
  end

  def calculate_percent_completed_units(current_units,village)
    result = {}
    village.model.troops.to_h.each do |unit,total|
      result[unit] = total.to_f != 0 ? current_units[unit]/total.to_f : 1
    end
    return OpenStruct.new result
  end

  def compute_less_complete_unit(target_train,percent_completed)
    units = target_train.to_h.select{|k,v| v>0 }.keys
    percent_completed = percent_completed.to_h.select {|k,v| units.include?(k.to_s) }
    unit = percent_completed.sort{|a,b| a[1] <=> b[1] }[0][0]
  end

  def recruit village
    train_screen = Screen::Train.new(village: village.vid)
    units_to_train = calculate_units_to_train(train_screen,village)
    percent_completed = calculate_percent_completed_units(train_screen.complete_units.clone.to_h,village)

    trail_util = Time.zone.now + 1.hour

    to_train = Troop.new

    stop = false

    resources = train_screen.resources
    current_units = train_screen.complete_units.clone
    release_times = train_screen.release_time.clone

    loop do 
      release_times = release_times.select{|k,v| v <= Time.zone.now + 1.hour}
      percent_completed = calculate_percent_completed_units(current_units.to_h,village)
      target_units = percent_completed.to_h.select {|unit,percent| percent != 1}.keys
      target_buildings = target_units.map{|unit| Troop.get_building(unit)}.uniq

      enter = false
      target_buildings.map do |building|
        elements = release_times.select{|k,v| target_buildings.include?(k.to_sym)}.to_a.sort{|a,b| a[1] <=> b[1]}
        if (elements.empty?)
          next
        end
        next_release_building = elements[0][0]
        
        next if (next_release_building != building.to_s)

        target_train = units_to_train.from_building building
        less_complete_unit = compute_less_complete_unit(target_train,percent_completed)
        cost = train_screen.train_info[less_complete_unit.to_s].to_resource
        train_seconds = train_screen.train_info[less_complete_unit.to_s]["build_time"]

        if (resources.include?(cost))
          enter = true
          to_train[less_complete_unit] += 1
          current_units[less_complete_unit] += 1
          release_times[building.to_s] += train_seconds
        end

      end


      stop = true if (!enter)

      break if stop
    end
    
    if (!to_train.to_h.select{|k,v| v > 0}.empty?)
      train_screen.train(to_train)
    end
    return nil
  end

  def two_itens_in_build_queue?(village)
    main_screen = Screen::Main.new(id: village.vid)
    main_screen.queue.size >= 1
  end

  def build_priorities(current,main_screen)
    if (main_screen.farm_alert)
      current.attributes.map do |k,v|
        if (k.to_sym != :farm)
          current[k] = 0
        end
      end
      return current
    end
    return current
  end

  def build village
    main_screen = Screen::Main.new(id: village.vid)

    config = village.model.buildings
    return if (main_screen.queue.size >= 1)

    current = Model::Buildings.new(main_screen.buildings.map{|k,v| [k,v.level]}.to_h)

    main_screen.queue.map do |queue_item|
      current[queue_item.building]
    end

    remaining = build_priorities((config - current).remove_negative,main_screen)

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
