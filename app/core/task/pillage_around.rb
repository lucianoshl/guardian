class Task::PillageAround < Task::Abstract
#
  # in_development

  sleep? false

  def run

    candidates = Village.pillage_candidates.any_of({:next_event => nil}, {:next_event.lte => Time.zone.now}).asc(:next_event)

    info "Running for #{candidates.size} candidates"
    candidates.each do |target|
      current_state =target.state || 'send_command'

      @target = target
      @origin = Village.my.first
      @place = Screen::Place.new(village: @origin.id)

      begin
        state,_next_event = self.send("state_#{current_state}")
      rescue DeletedPlayerException => e
        target.delete
        next
      end
      binding.pry if (_next_event.nil? ||  state.nil?)

      @target.state = state

      @target.next_event = _next_event
      @target.save

    end
    return Village.pillage_candidates.map(&:next_event).sort.first || (Time.zone.now + 1.hour)
  end

  def state_send_command

    command = @place.has_command(@target)
    if (!command.nil?) 
      return move_to_waiting_report(command)
    end

    @target.last_report.nil? ? state_send_recognition : state_waiting_report
  end

  def state_send_recognition
    base_attack = Troop.new(spy: 4)

    if (!@place.units.contains(base_attack)) then
      return move_to_waiting_troops(base_attack)
    else
      begin
        command = @place.send_attack(@origin,@target,base_attack)
        move_to_waiting_report(command)
      rescue NewbieProtectionException => exception
        move_to_newbie_protection(exception.expires)
      rescue SharedConectionException => exception
        move_to_shared_connection
      rescue BannedUserException => exception
        move_to_banned
      end
    end
    
  end

  def state_banned
    state_send_command
  end

  def state_waiting_troops
    state_send_command
  end
  
  def state_newbie_protection
    state_send_command
  end 

  def state_waiting_resources
    state_send_command
  end 

  def state_shared_connection
    state_send_command
  end 

  def state_has_troops
    state_send_command
  end 

  def state_waiting_report
    Screen::ReportView.load_all
    last_report = @target.last_report
    if (last_report.nil?)
      binding.pry
      return state_send_recognition
    end

    expire_report_in = 3.hours

    resource_min = 200

    if (last_report.resources.nil? || (Time.zone.now - last_report.occurrence)/expire_report_in > 1)
      return state_send_recognition
    end

    if (last_report.status == :lost || last_report.has_troops?)
      return move_to_has_troops
    end

    total_resources = last_report.resources.total
    troops = @place.units.distribute(total_resources)

    if ((!last_report.resources.nil? && last_report.resources.total < resource_min) ||
      troops.carry < resource_min)
      return move_to_waiting_resources(@target)
    end

    if (troops.total.zero?)
      return move_to_waiting_troops(nil)
    end

    while (!troops.win?(repot.moral,report.target_buildings["wall"]))
      begin
        troops = troops.upgrade(@place.units - troops,total_resources)
      rescue ImpossibleUpgrade => e
        return move_to_waiting_troops(nil)
      end
    end

    begin
      troops.validate
      command = @place.send_attack(@origin,@target,troops)
      return move_to_waiting_report(command)
    rescue NewbieProtectionException => exception
      return move_to_newbie_protection(exception.expires)
    rescue SharedConectionException => exception
      return move_to_shared_connection
    end
  end

  def move_to_shared_connection
    return next_event(Time.zone.now + 2.hour)
  end

  def move_to_waiting_resources(village)
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

  def move_to_has_troops
    return next_event(Time.zone.now + 1.day)
  end

  def move_to_waiting_troops(troops_to_wait)
    commands_with_order = @place.commands.sort{|a,b| a.occurence <=> b.occurence}
    next_returning = commands_with_order.select(&:returning).first || commands_with_order.first
    return next_event(next_returning.occurence)
  end

  def next_event date
    backtrace = Thread.current.backtrace
    state = backtrace[2].scan(/`(.*)'/).first.first.gsub('move_to_','')
    info("Target #{@target} going to #{state} at #{date}")
    [state,date]
  end

end
