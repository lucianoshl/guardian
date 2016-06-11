class Task::PillageAround < Task::Abstract

  # in_development

  def run
    fix_strong
    fix_ally

    candidates = Village.pillage_candidates.any_of({:next_event => nil}, {:next_event.lte => Time.zone.now}).to_a
    info "Running for #{candidates.size} candidates"
    candidates.map do |target|
      current_state =target.state || 'send_command'

      @target = target
      @origin = Screen::Overview.new.villages.first
      @place = Screen::Place.new(village: @origin.id)

      state,_next_event = self.send("state_#{current_state}")
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

  def state_waiting_report
    Screen::ReportView.load_all
    last_report = @target.last_report
    if (last_report.nil?)
      binding.pry
      return state_send_recognition
    end

    expire_report_in = 3.hours

    if (last_report.resources.nil? || (Time.zone.now - last_report.occurrence)/expire_report_in > 1)
      return state_send_recognition
    end

    if (!last_report.resources.nil? && last_report.resources.total < 100)
      return move_to_waiting_resources(@target)
    end

    tota_resources = last_report.resources.total
    troops = @place.units.distribute(tota_resources)

    if (troops.total.zero?)
      return move_to_waiting_troops(nil)
    end

    while (!troops.win?)
      begin
        troops = troops.upgrade(@place.units - troops,tota_resources)
      rescue ImpossibleUpgrade => e
        return move_to_waiting_troops(nil)
      end
    end

    begin
      binding.pry
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

  def fix_strong
    Village.where(state: :strong).update_all(state:nil)
    (Village.all - Village.pillage_candidates).map do |village|
      village.next_event = nil
      village.state = :strong
      village.save
    end
  end

  def fix_ally
    player_ally = User.first.player.ally
    if (!player_ally.nil?)
      Village.where(state: :ally).update_all(state:nil)
      Player.where(ally: player_ally).includes(:villages).map(&:villages).flatten.pmap do |village|
        village.next_event = nil
        village.state = :ally
        village.save
      end
    end
  end

end
