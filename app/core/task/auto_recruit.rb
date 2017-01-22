module Coiner

  def coins(village)
    snob_screen = Screen::Snob.new(village: village.vid)
    if (snob_screen.enabled && snob_screen.possible_coins > 0 && (snob_screen.possible_snobs < 10 || snob_screen.storage_alert))

        coins = snob_screen.storage_alert ? (snob_screen.possible_coins/2).floor.to_i : snob_screen.possible_coins

        snob_screen.do_coin(coins)
    end
  end

end

module Builder

  def build village
    main_screen = Screen::Main.new(village: village.vid)

    config = current_build_config(main_screen,village.model)
    return main_screen.queue.last.completed_in if (main_screen.queue.size >= 2)

    current = Model::Buildings.new(main_screen.buildings.map{|k,v| [k,v.level]}.to_h)

    # remove queue
    main_screen.queue.map do |queue_item|
      current[queue_item.building] += 1
    end

    # pop = Population.from_config(village.model)
    # binding.pry

    remaining = (config - current).remove_negative
    remaining = remove_without_population(remaining,main_screen)
    remaining = build_priorities(remaining,main_screen,config)

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

    to_build = to_build.select {|a| !(main_screen.resources - a.cost).has_negative? }

    sorted = to_build.sort{|b,a| a.remaining_resources_if_build <=> b.remaining_resources_if_build }

    wall_item = sorted.select{|a| a.name == "wall"}

    if (wall_item.size > 0)
      sorted = wall_item
    end

    target = sorted.first

    return if target.nil? || !main_screen.resources.include?(target.cost)

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


  def build_priorities(current,main_screen,config)
    result = current.clone

    storage_info = main_screen.buildings["storage"]
    real_storage_alert = storage_info.level != 30 && main_screen.storage_alert && !storage_info.in_queue

    farm_info = main_screen.buildings["farm"]
    real_farm_alert = farm_info.level != 30 && main_screen.farm_alert && !farm_info.in_queue

    if (real_farm_alert || real_storage_alert)
      result.attributes.map do |k,v|
        result[k] = 0
      end
      result['farm'] = 1 if (real_farm_alert)
      result['storage'] = 1 if (real_storage_alert)
    end

    return result
  end

  def remove_without_population(current,main_screen)
    result = current.clone
    result.my_fields.map do |building|
      building_meta = main_screen.buildings[building]
      if (!building_meta.nil? && result[building] > 0 && building_meta.pop > main_screen.free_population)
        result[building] = 0
      end
    end
    return result
  end

  def current_build_config(main_screen,model)
    current = Model::Buildings.new(main_screen.buildings.map{|k,v| [k,v.level]}.to_h)
    config = nil

    priorities = model.priorities.clone.push(model.buildings)

    priorities.map do |config_item|
      config = config_item
      break if (config_item - current).remove_negative.total > 0
    end

    return config
  end

end

module Recruiter


  def recruit village
    train_screen = Screen::Train.new(village: village.vid)
    units_to_train = calculate_units_to_train(train_screen,village)
    percent_completed = calculate_percent_completed_units(train_screen.complete_units.clone.to_h,village)

    trail_util = Time.zone.now + self.class._performs_to + 10.minutes

    to_train = Troop.new

    stop = false

    resources = train_screen.resources
    current_units = train_screen.complete_units.clone
    release_times = train_screen.release_time.clone

    loop do 
      release_times = release_times.select{|k,v| v <= Time.zone.now + self.class._performs_to}
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

        next if (target_train.total.zero?)

        less_complete_unit = compute_less_complete_unit(target_train,percent_completed)
        cost_info = train_screen.train_info[less_complete_unit.to_s]

        if (!cost_info.nil?)
          cost = cost_info.to_resource
          train_seconds = train_screen.train_info[less_complete_unit.to_s]["build_time"]

          if (resources.include?(cost))
            enter = true
            to_train[less_complete_unit] += 1
            current_units[less_complete_unit] += 1
            release_times[building.to_s] += train_seconds
          end
        else
          # do research
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

  def calculate_units_to_train(train_screen,village)
    if (village.model.troops.nil?)
      return Troop.new
    end

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

end

module Transporter

  def clean_reports
    Screen::ReportList.new(mode: 'trade').clear_all
  end

  def distribute_resources

    clean_reports

    all_markets = Village.my.map {|v| Screen::Market.new(village: v.vid) }

    markets = (all_markets.map {|a| [a.village.vid,a]}).to_h

    return if (all_markets.size < 2)

    all_resources = Resource.new

    markets.values.map {|v| all_resources += v.resources + v.trader.incomming }

    storage_levels = all_markets.map{|a| [a.village.vid,a.building_levels['storage'].to_i] }.to_h
    lower_villages = storage_levels.select {|village,level| level < 30}

    distribution = {}
    all_markets.map {|market| distribution[market.village.vid] = Resource.new }

    unit = 1000 

   loop do
      exchange = false

      ['wood','stone','iron'].map do |resource|
        minimal_vid = get_minimal(distribution,resource,markets)
        puts "#{all_resources.wood} #{all_resources.stone} #{all_resources.iron}"
        if (all_resources[resource] >= unit)

          distribution[minimal_vid][resource] += unit
          all_resources[resource] -= unit
          exchange = true
        end
      end

      break if (!exchange)
    end

    equal_distribution = distribution.clone

    lower_villages = equal_distribution.select {|k,v| lower_villages.include?(k)}
    normal_villages = equal_distribution.select {|k,v| !lower_villages.include?(k)}

    loop do
      exchange = false

      ['wood','stone','iron'].map do |resource|
        minimal_vid = get_minimal(lower_villages,resource,markets)
        normal_village = get_max(normal_villages,resource,markets)
        puts "#{all_resources.wood} #{all_resources.stone} #{all_resources.iron}"
        storage_in_limit = lower_villages[minimal_vid][resource]/markets[minimal_vid].storage_size.to_f >= 0.9
        if (normal_villages[normal_village][resource] >= unit && !storage_in_limit)

          lower_villages[minimal_vid][resource] += unit
          normal_villages[normal_village][resource] -= unit
          exchange = true
        end
      end

      break if (!exchange)
    end


    target_distribution = lower_villages.merge(normal_villages)

    transport = distribute(target_distribution,markets)

    markets.map do |vid,market|
      if (!transport[vid].nil? && transport[vid].size > 0) 
        transport[vid].map do |vid_target,resources|
          market.send_resource(markets[vid_target].village,resources) 
        end
      end
    end

  end

  def distribute(target,markets)
    unit = 1000
    actual = {}
    markets.map { |k,v| actual[k] = v.resources + v.trader.incomming  }

    transport = {}

    loop do
      exchange = false

      ['wood','stone','iron'].map do |resource|
        missing_vid = find_missing(target,actual,resource)
        remaining_vid = find_remaining(target,actual,resource)

        puts "M: #{missing_vid} V: #{remaining_vid}"

        is_transporting = (transport[missing_vid]|| {}).keys.include?(remaining_vid)
        is_transporting &&= transport[missing_vid][remaining_vid][resource] > 0

        if (actual[remaining_vid][resource] >= unit && !is_transporting)
          actual[missing_vid][resource] += unit
          actual[remaining_vid][resource] -= unit

          transport[remaining_vid] ||= {}
          transport[remaining_vid][missing_vid] ||= Resource.new
          transport[remaining_vid][missing_vid][resource] += unit
          exchange = true
        end
      end

      break if (!exchange)
    end

    return transport
  end

  def find_missing(target,actual,resource)
    diferences = {}
    target.map do |v,r|
      diferences[v] = actual[v] - r
    end

    (diferences.sort do |a,b|
      a[1][resource] <=> b[1][resource]
    end).first.first
  end

  def find_remaining(target,actual,resource)
    diferences = {}
    target.map do |v,r|
      diferences[v] = actual[v] - r
    end

    (diferences.sort do |a,b|
      b[1][resource] <=> a[1][resource]
    end).first.first
  end


  def get_minimal(distribution,resource,markets)
    (distribution.to_a.sort do |a,b| 
      a[1][resource]/markets[a.first].storage_size.to_f <=> b[1][resource]/markets[b.first].storage_size.to_f
    end).first.first
  end

  def get_max(distribution,resource,markets)
    (distribution.to_a.sort do |b,a| 
      a[1][resource]/markets[a.first].storage_size.to_f <=> b[1][resource]/markets[b.first].storage_size.to_f
    end).first.first
  end

  #   storage_use = {}

  #   all_markets.map do |market|
  #     storage_use[market.village.vid] = (market.resources + market.trader.incomming)/market.storage_size.to_f
  #     storage_use[market.village.vid].storage_unit = 1000/market.storage_size.to_f
  #   end

  #   storage_levels = all_markets.map{|a| [a.village.vid,a.building_levels['storage'].to_i] }.to_h


  #   # original_storage_use = Marshal.load(Marshal.dump(storage_use.clone)) # deep clone

  #   storage_use_transport = generate_distributed_resources(storage_use)

  #   lower_villages = storage_levels.select {|village,level| level < 30}

  #   lower_villages.keys.map do |village_id|
  #     target = 0.1
  #     storage_use_transport[village_id].wood -= target - storage_use_transport[village_id].wood
  #     storage_use_transport[village_id].stone -= target - storage_use_transport[village_id].wood
  #     storage_use_transport[village_id].stone -= target - storage_use_transport[village_id].wood
  #   end

  #   storage_use_transport = generate_distributed_resources(storage_use_transport)

  #   markets.map do |vid,market|
  #     if (!storage_use_transport[vid].outcoming.nil?)
  #       storage_use_transport[vid].outcoming.map do |vid_target,resources|
  #         market.send_resource(markets[vid_target].village,Resource.new(resources)*1000)
  #       end
  #     end
  #   end

  # end

  # def get_min_max(storage_use,resource)
  #   result = []

  #   result[0] = storage_use.min do |a,b|
  #     a[1][resource] <=> b[1][resource]
  #   end

  #   result[1] = storage_use.max do |a,b|
  #     a[1][resource] <=> b[1][resource]
  #   end

  #   result.map{|a| a.first}
  # end
end



class Task::AutoRecruit < Task::Abstract

  include Coiner
  include Recruiter
  include Builder
  include Transporter

  performs_to 1.hour

  def run
    dates = []
    Village.my.map do |village|
      if (!village.model.nil?)
          recruit(village) if (village.disable_auto_recruit != true)
          dates << build(village)
          coins(village)
      end
    end

    distribute_resources
 
    list = dates.flatten.compact.sort{|a,b| a <=> b}

    Rails.logger.info("date_list=#{list}")

    next_hour = Time.zone.now + self.class._performs_to
    !list.first.nil? && list.first <= (next_hour) ? list.first : next_hour
  end

end