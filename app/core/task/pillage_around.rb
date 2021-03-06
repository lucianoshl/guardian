class Task::PillageAround < Task::Abstract

  def closer_villages(target)
    @my_villages.select{|a| a.distance(target) <= Config.pillager.distance(10) }.sort do |a,b|
      a.distance(target) <=> b.distance(target)
    end
  end

  def get_place village
    Screen::Place.get(village.vid)
  end

  def run
    Rails.logger.info('Start pillage arround')
    Screen::Place.reset

    Mobile::ReportList.load_all

    candidates = Village.pillage_candidates.any_of({:next_event => nil}, {:next_event.lte => Time.zone.now}).asc(:next_event)

    @my_villages = Village.my.where(use_in_pillage: true).to_a

    info "Running for #{candidates.size} candidates"

    candidates = candidates.map do |target|
      closer = closer_villages(target)
      distance = closer.first.nil? ? -1 : closer.first.distance(target)
      [target,closer,distance]
    end

    candidates = candidates.sort{|a,b| a[2] <=> b[2]}

    
    index = 0
    candidates.each do |target,closer_villages|
      index += 1
      @target = target
      @origin_candidates = closer_villages

      if (@origin_candidates.empty?)
        @target.state = "far_away"
      end

      @origin = @origin_candidates.shift

      current_state = equivalent_state(target.state || 'send_command')

      begin
        info("-----------------------------------------------------------------------")
        info("#{candidates.size}/#{index}")
        info("Running state #{current_state} for #{@target} (#{@target.name}) using #{@origin.nil? ? "FAR AWAY!!" : @origin.name}")
        info("@origin=#{@origin.nil? ? "nil" : @origin.vid}")
        info("@candidates=#{@origin_candidates.map(&:vid)}")
        state,_next_event = self.send("state_#{current_state}")
      rescue DeletedPlayerException => e
        target.delete
        next
      rescue Exception => e
        Rails.logger.error("Error in village #{target.to_s}".white.on_red)
        ApplicationError.register(e)
        next
      end

      info("Finish Running for #{@target}")
      raise Exception.new("state not returned _next_event or state") if (_next_event.nil? || state.nil?)

      @target.state = state

      @target.next_event = _next_event
      @target.save

    end
    
    next_execute = Village.pillage_candidates.map(&:next_event).compact.sort.first || (Time.zone.now + 1.hour)

    next_five = Time.zone.now + 5.minutes

    return next_execute <= next_five ? next_five : next_execute
  end

  def state_send_command

    command = get_place(@origin).has_command(@target)
    if (!command.nil?) 
      return move_to_waiting_report(command)
    end

    @target.last_report.nil? ? state_send_recognition : state_waiting_report
  end 

  def state_send_recognition
    # spies = @target.player_id.nil? ? 4 : 5
    base_attack = Troop.new(spy: Screen::Place.spy_qte(@target))

    if (!get_place(@origin).free_units.contains(base_attack)) then
      return move_to_waiting_spies(base_attack)
    else
      return send_attack(base_attack)   
    end
  end

  def equivalent_state state
    state = state.to_s
    equivalents = {}
    equivalents['banned'] = 'send_command'
    equivalents['waiting_troops'] = 'send_command'
    equivalents['waiting_strong_troops'] = 'send_command'
    equivalents['waiting_spies'] = 'send_command'
    equivalents['newbie_protection'] = 'send_command'
    equivalents['invited_player'] = 'send_command'
    equivalents['waiting_resources'] = 'send_command'
    equivalents['shared_connection'] = 'send_command'
    equivalents['trops_without_spy'] = 'send_command'
    equivalents['waiting_population'] = 'send_command'
    equivalents['has_troops'] = 'waiting_report'
    return equivalents[state] || state
  end

  def state_far_away
    if (closer_villages(@target).empty?)
      return ["far_away",Time.zone.now + 1.day]
    end
    state_send_command
  end

  def state_waiting_partner
    last_report_partner =  Partner.last_report(@target)

    if (!last_report_partner.nil? && (@target.last_report.nil? || @target.last_report.occurrence < last_report_partner.occurrence))
      last_report_partner.save
    end

    state_send_command
  end 

  def state_waiting_report
    last_report = @target.last_report
    if (last_report.nil?)
      return state_send_recognition
    end

    if (last_report.status == :lost || last_report.has_spy_losses?)
      return move_to_has_troops
    end

    expire_report_in = Config.pillager.report_expiration_time(3).hours

    resource_min = Config.pillager.min_resource_to_pillage(100)  

    if (last_report.resources.nil? || (Time.zone.now - last_report.occurrence)/expire_report_in > 1)
      return state_send_recognition
    end

    if (last_report.has_troops?)
      return move_to_trops_without_spy
    end

    total_resources = last_report.resources.total

    troops = get_place(@origin).free_units.distribute(total_resources)


    if ((!last_report.resources.nil? && last_report.resources.total < resource_min))
      # total_resources = resource_min
      # troops = get_place(@origin).free_units.distribute(resource_min)
      return move_to_waiting_resources(@target)
    end

    if (troops.total.zero?)
      return move_to_waiting_troops(nil)
    end

    # night_bonus = (Time.zone.now.beginning_of_day..Time.zone.now.beginning_of_day+8.hours).cover?(Time.zone.now)

    if (!get_place(@origin).free_units.ram.nil? && get_place(@origin).free_units.ram > 0)
      rams = last_report.rams_to_destroy_wall
      troops.ram = get_place(@origin).free_units.ram < rams ? get_place(@origin).free_units.ram : rams
    end


    while (!troops.win?(last_report.moral,last_report.target_buildings["wall"],false))
      begin
        Rails.logger.info("Running simulator #{troops.to_h}")
        troops = troops.upgrade(get_place(@origin).free_units - troops,total_resources)
      rescue ImpossibleUpgrade => e
        return move_to_waiting_strong_troops(nil)
      end
    end

    return send_attack(troops)
  end

  def send_attack troops
    command = get_place(@origin).has_command(@target)
    if (!command.nil?)
      return move_to_waiting_report(command)
    end
    
    begin
      command = get_place(@origin).send_attack(@target,troops)
      info("Command sent with #{troops.to_h}")
      return move_to_waiting_report(command)
    rescue NewbieProtectionException => exception
      move_to_newbie_protection(exception.expires)
    rescue SharedConectionException => exception
      move_to_shared_connection
    rescue InvitedPlayerException => exception
      move_to_invited_player(exception.expires)
    rescue PartnerAttackingException => exception
      move_to_waiting_partner(exception.release)
    rescue BannedUserException => exception
      move_to_banned
    rescue InexistentVillage => e
      move_to_banned
    rescue NeedsMorePopulationException => exception
      move_to_waiting_population
    end
  end

  def increase_population(troops,population)
    troops_old = troops
    begin
      troops = troops.increase_population(get_place(@origin).free_units,population)
    rescue ImpossibleUpgrade => e
      return move_to_waiting_troops(nil)
    end

    return send_attack(troops)
  end

  def move_to_shared_connection
    info("now moving to " + __method__.to_s.gsub('move_to_','').black.on_white)
    return next_event(Time.zone.now + 2.hour)
  end

  def move_to_waiting_partner(release_time)
    info("now moving to " + __method__.to_s.gsub('move_to_','').black.on_white)
    return next_event(release_time + 10.minutes)
  end

  def move_to_trops_without_spy
    info("now moving to " + __method__.to_s.gsub('move_to_','').black.on_white)
    return next_event(Time.zone.now + 3.hour)
  end

  def move_to_waiting_resources(village=nil)
    info("now moving to " + __method__.to_s.gsub('move_to_','').black.on_white)
    return next_event(Time.zone.now + 3.hours)
  end

  def move_to_waiting_population
    info("now moving to " + __method__.to_s.gsub('move_to_','').black.on_white)
    return next_event(Time.zone.now + 3.hours)
  end

  def move_to_waiting_report(command)
    info("now moving to " + __method__.to_s.gsub('move_to_','').black.on_white)
    return next_event(command.occurence + 1.second)
  end
 
  def move_to_banned
    info("now moving to " + __method__.to_s.gsub('move_to_','').black.on_white)
    return next_event(Time.zone.now + 1.hour)
  end

  def move_to_newbie_protection(date)
    info("now moving to " + __method__.to_s.gsub('move_to_','').black.on_white)
    return next_event(date)
  end

  def move_to_invited_player(date)
    info("now moving to " + __method__.to_s.gsub('move_to_','').black.on_white)
    return next_event(date)
  end

  def move_to_has_troops
    info("now moving to " + __method__.to_s.gsub('move_to_','').black.on_white)
    return next_event(Time.zone.now + 1.day)
  end

  def move_to_waiting_strong_troops(troops_to_wait)
    info("now moving to " + __method__.to_s.gsub('move_to_','').black.on_white)
    # return next_event(next_returning)
    return next_event(Time.zone.now + 3.hours)
  end

  def move_to_waiting_troops(troops_to_wait)
    info("now moving to " + __method__.to_s.gsub('move_to_','').black.on_white)
    return next_event(next_returning)
  end

  def move_to_waiting_spies(troops_to_wait)
    info("now moving to " + __method__.to_s.gsub('move_to_','').black.on_white)
    return next_event(next_returning)
  end

  def next_returning
    other = @origin_candidates.shift

    if (!other.nil?)
      puts "Change candidate #{@origin.name} to #{other.name}"
      @origin = other
      return state_send_recognition
    end

    info("Checking next commands for all villages...")
    commands_with_order = Screen::Place.all.select{|a| a.village.distance(@target) <= Config.pillager.distance(10) }.map(&:commands).flatten.sort{|a,b| a.occurence <=> b.occurence}

    result = commands_with_order.select(&:returning).first || commands_with_order.first
    result = result.nil? ? (Time.zone.now + 1.hour) : result.occurence
    info("... next command in #{result}")
    return result
  end

  def next_event date
    if (date.class == Array && date.size == 2)
      return date
    end
    backtrace = Thread.current.backtrace
    state = backtrace[2].scan(/`(.*)'/).first.first.gsub('move_to_','')
    info("Target #{@target} going to #{state} at #{date}")
    [state,date]
  end

end
