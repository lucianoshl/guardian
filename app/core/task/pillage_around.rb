class Task::PillageAround < Task::Abstract

  def run
    candidates = Village.where(is_barbarian:true)

    candidates.map do |target|
      current_state =target.state || 'send_command'
      @target = target
      @origin = Screen::Overview.new.villages.first
      self.send(current_state)
    end

    binding.pry
  end

  def send_command
    @target.last_unsed_report.nil? ? send_recognition : send_pillage
  end

  def send_recognition
    place_screen = Screen::Place.new(village: @origin.id)

    base_attack = Troop.new(spear: 5, sword:3)

    if (!place_screen.units.contains(base_attack)) then
      waiting_troops(base_attack)
    else
      command = place_screen.send_attack(@origin,@target,base_attack)
      waiting_report(command)
    end
    
  end

  def send_pillage
    binding.pry
  end 

end