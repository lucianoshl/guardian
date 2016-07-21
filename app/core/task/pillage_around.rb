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
    candidates = Village.pillage_candidates.any_of({:next_event => nil}, {:next_event.lte => Time.zone.now}).asc(:next_event)

    @my_villages = Village.my.to_a

    info "Running for #{candidates.size} candidates"

    candidates = candidates.map do |target|
      closer = closer_villages(target)
      [target,closer,closer.first.distance(target)]
    end

    candidates = candidates.sort{|a,b| a[2] <=> b[2]}

    Screen::ReportView.load_all
    
    candidates.each do |target,closer_villages|
      @target = target
      @origin_candidates = closer_villages

      if (@origin_candidates.empty?)
        @target.state = "far_away"
      end

      @origin = @origin_candidates.shift

      current_state = equivalent_state(target.state || 'send_command')

      begin
        info("Running state #{current_state} for #{@target} using #{@origin.nil? ? "FAR AWAY!!" : @origin.name}")
        state,_next_event = self.send("state_#{current_state}")
      rescue DeletedPlayerException => e
        target.delete
        next
      end
      raise Exception.new("state not returned _next_event or state") if (_next_event.nil? || state.nil?)

      @target.state = state

      @target.next_event = _next_event
      @target.save

    end
    
    return Village.pillage_candidates.map(&:next_event).compact.sort.first || (Time.zone.now + 1.hour)
  end

  def state_send_command

    command = get_place(@origin).has_command(@target)
    if (!command.nil?) 
      return move_to_waiting_report(command)
    end

    @target.last_report.nil? ? state_send_recognition : state_waiting_report
  end

  def state_send_recognition
    spies = @target.player.nil? ? 4 : 5
    base_attack = Troop.new(spy: spies)

    if (!get_place(@origin).units.contains(base_attack)) then
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
    equivalents['waiting_spies'] = 'send_command'
    equivalents['newbie_protection'] = 'send_command'
    equivalents['invited_player'] = 'send_command'
    equivalents['waiting_resources'] = 'send_command'
    equivalents['shared_connection'] = 'send_command'
    equivalents['trops_without_spy'] = 'send_command'
    equivalents['waiting_population'] = 'send_command'
    equivalents['has_troops'] = 'send_command'
    return equivalents[state] || state
  end

  def state_far_away
    if (closer_villages.empty?)
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

    if (last_report.has_troops?)
      return move_to_trops_without_spy
    end

    expire_report_in = Config.pillager.report_expiration_time(3).hours

    resource_min = Config.pillager.min_resource_to_pillage(100)  

    if (last_report.resources.nil? || (Time.zone.now - last_report.occurrence)/expire_report_in > 1)
      return state_send_recognition
    end

    total_resources = last_report.resources.total

    troops = get_place(@origin).units.distribute(total_resources)


    if ((!last_report.resources.nil? && last_report.resources.total < resource_min))
      return move_to_waiting_resources(@target)
    end

    if (troops.total.zero?)
      return move_to_waiting_troops(nil)
    end

    # night_bonus = (Time.zone.now.beginning_of_day..Time.zone.now.beginning_of_day+8.hours).cover?(Time.zone.now)

    if (!get_place(@origin).units.ram.nil? && get_place(@origin).units.ram > 0)
      rams = last_report.rams_to_destroy_wall
      troops.ram = get_place(@origin).units.ram < rams ? get_place(@origin).units.ram : rams
    end


    while (!troops.win?(last_report.moral,last_report.target_buildings["wall"],false))
      begin
        troops = troops.upgrade(get_place(@origin).units - troops,total_resources)
      rescue ImpossibleUpgrade => e
        return move_to_waiting_troops(nil)
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
    rescue NeedsMorePopulationException => exception
      move_to_waiting_population
    end
  end

  def move_to_shared_connection
    return next_event(Time.zone.now + 2.hour)
  end

  def move_to_waiting_partner(release_time)
    return next_event(release_time + 10.minutes)
  end

  def move_to_trops_without_spy
    return next_event(Time.zone.now + 3.hour)
  end

  def move_to_waiting_resources(village)
    return next_event(Time.zone.now + 1.hour)
  end

  def move_to_waiting_population
    return next_event(Time.zone.now + 1.hour)
  end

  def move_to_waiting_report(command)
    return next_event(command.occurence)
  end
  def move_to_banned
    return next_event(Time.zone.now + 1.day)
  end

  def move_to_newbie_protection(date)
    return next_event(date)
  end

  def move_to_invited_player(date)
    return next_event(date)
  end

  def move_to_has_troops
    return next_event(Time.zone.now + 1.day)
  end

  def move_to_waiting_troops(troops_to_wait)
    next_command
  end

  def move_to_waiting_spies(troops_to_wait)
    next_command
  end

  def next_command
    other = @origin_candidates.shift

    if (!other.nil?)
      puts "Change candidate #{@origin.name} to #{other.name}"
      @origin = other
      return state_send_recognition
    end

    commands_with_order = Screen::Place.all.select{|a| a.village.distance(@target) <= Config.pillager.distance(10) }.map(&:commands).flatten.sort{|a,b| a.occurence <=> b.occurence}

    next_returning = commands_with_order.select(&:returning).first || commands_with_order.first
    next_returning = next_returning.nil? ? (Time.zone.now + 1.hour) : next_returning.occurence
    return next_event(next_returning)
  end

  def next_event date
    backtrace = Thread.current.backtrace
    state = backtrace[2].scan(/`(.*)'/).first.first.gsub('move_to_','')
    info("Target #{@target} going to #{state} at #{date}")
    [state,date]
  end

end
