module Coiner

  def coins(village)
    snob_screen = Screen::Snob.new(village: village.vid)
    # if (snob_screen.enabled && snob_screen.possible_coins > 0 && (snob_screen.possible_snobs < 10 || snob_screen.storage_alert))
    if (snob_screen.enabled && snob_screen.possible_coins > 4 )

        # coins = snob_screen.storage_alert ? (snob_screen.possible_coins/2).floor.to_i : snob_screen.possible_coins
        coins = snob_screen.possible_coins - 4

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

    last_complete_time = main_screen.queue.last.completed_in if (main_screen.queue.size > 1)

    return last_complete_time if target.nil? || !main_screen.resources.include?(target.cost)

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

    priorities = model.priorities.clone
    priorities.push(model.buildings) if (!model.buildings.nil?)

    priorities.map do |config_item|
      config = config_item
      break if (config_item - current).remove_negative.total > 0
    end

    return config
  end

end

module Recruiter

  def calculate_population_for_buidings village,train_screen

    merged = Model::Buildings.new

    buildings_model = village.model.complete_building_model;
    buildings_model.my_fields.map do |building|
      merged[building] = buildings_model[building]
      if (buildings_model[building] < train_screen.building_levels[building])
        merged[building] = train_screen.building_levels[building]
      end
    end

    Utils::Population.from_config(merged)
  end

  def recruit village

    train_screen = Screen::Train.new(village: village.vid)

    reserved_for_buildings = calculate_population_for_buidings(village,train_screen)

    units_to_train = calculate_units_to_train(train_screen,village,reserved_for_buildings)
    snob_to_train = units_to_train.snob
    percent_completed = calculate_percent_completed_units(units_to_train,train_screen.complete_units.clone.to_h,village)

    Rails.logger.info("Units to train in #{village.name}: #{units_to_train.attributes}")
    Rails.logger.info("Village #{village.name} has percent units completed: #{percent_completed}")

    # trail_util = Time.zone.now + self.class._performs_to + 10.minutes
    trail_util = Time.zone.now + Config.auto_recrut.queue_time(1).hours

    to_train = Troop.new

    stop = false

    resources = train_screen.resources
    current_units = train_screen.complete_units.clone
    release_times = train_screen.release_time.clone

    need_research = units_to_train.my_fields.select{|unit| units_to_train[unit] > 0 }.select{|unit| train_screen.train_info[unit].nil? || train_screen.train_info[unit]['requirements_met'] == false }

    need_research.map do |need_research_unit|
      puts "Need research #{need_research_unit}".red.on_white
      units_to_train[need_research_unit] = 0
    end
    
    loop do 
      release_times = release_times.select{|k,v| v <= trail_util}
      percent_completed = calculate_percent_completed_units(units_to_train,current_units.to_h,village)
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

        # && cost_info["requirements_met"]
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
          Rails.logger.error("Implementar pesquisa no ferreiro".on_red)
        end
      end


      stop = true if (!enter)

      break if stop
    end

    if (snob_to_train > 0)
      Screen::Snob.new(village: village.vid).train(snob_to_train)
    end

    if (!to_train.to_h.select{|k,v| v > 0}.empty?)
      Rails.logger.info("Training #{to_train.to_h} in #{village.name}")
      train_screen.train(to_train)
    else
      Rails.logger.info("Nothing to train in #{village.name}")
    end

    return nil
  end

  def calculate_units_to_train(train_screen,village,reserved_population)
    if (village.model.troops.nil?)
      return Troop.new
    end

    limit_units = 24000 - reserved_population


    troops_model = village.model.troops.clone

    troops_model.my_fields.map do |unit|
      if (troops_model[unit] >= 1)
        limit_units -= troops_model[unit] * Unit.get(unit).population
      end
    end

    troops_model.my_fields.map do |unit|
      if (troops_model[unit] < 1 && troops_model[unit] > 0)
        troops_model[unit] = ((limit_units * troops_model[unit])/Unit.get(unit).population).floor
      end 
    end

    tropas_sobrando = (troops_model - train_screen.complete_units).to_h.select{|k,v| v < 0}.map{|k,v| [k,v*-1]}.to_h
    Rails.logger.info "Tropas sobrando #{tropas_sobrando} em #{village.vid}".on_red if (tropas_sobrando.size > 0)
    to_train = (troops_model - train_screen.complete_units).remove_negative
    return to_train
  end

  def calculate_percent_completed_units(units_to_train,current_units,village)
    result = {}
    units_to_train.to_h.each do |unit,total|
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

    max_storage = storage_levels.values.max

    lower_villages = storage_levels.select {|village,level| level < max_storage}

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
        # puts "#{all_resources.wood} #{all_resources.stone} #{all_resources.iron}"
        storage_in_limit = lower_villages[minimal_vid][resource]/markets[minimal_vid].storage_size.to_f >= 0.6
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
    villages_with_model = Village.my.select{|v| !v.model.nil? }

    villages_with_model.map do |village|
      Rails.logger.info("Running for village #{village.name}: start")
      if (!village.model.nil?)
          recruit(village) if (village.disable_auto_recruit != true)
          dates << build(village)
          coins(village)
      else
        Rails.logger.info("Village without config #{village.name}: skipping") 
      end
      Rails.logger.info("Running for village #{village.name}: end")
    end

    distribute_resources
 
    list = dates.flatten.compact.sort{|a,b| a <=> b}

    Rails.logger.info("date_list=#{list}")

    next_hour = Time.zone.now + self.class._performs_to
    !list.first.nil? && list.first <= (next_hour) ? list.first : next_hour
  end

end