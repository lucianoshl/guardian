class Task::PillageAround < Task::Abstract

  in_development

  def run
    candidates = Village.pillage_candidates.any_of({:next_event.exists => false}, {:next_event.lte => Time.zone.now}).to_a
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

    @target.last_unsed_report.nil? ? state_send_recognition : state_send_pillage
  end

  def state_send_recognition
    base_attack = Troop.new(spear: 5, sword:3)

    if (!@place.units.contains(base_attack)) then
      move_to_waiting_troops(@place,base_attack)
    else
      command = @place.send_attack(@origin,@target,base_attack)
      move_to_waiting_report(command)
    end
    
  end

  def state_send_pillage
    binding.pry
  end 

  def state_waiting_report
    Screen::Report.load_all
  end

  def move_to_waiting_report(command)
    return next_event(command.occurence)
  end

  def move_to_waiting_troops(place,troops_to_wait)
    commands_with_order = place.commands.sort{|a,b| a.occurence <=> b.occurence}
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