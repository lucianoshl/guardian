class Screen::Place < Screen::Logged

  attr_accessor :units,:commands,:incomings,:form,:unit_metadata

  url screen: 'place'  

  def send_attack origin,target,troops

    form.fill(troops.instance_values)
    form.fill(x: target.x , y: target.y)

    confirm_form = form.submit(form.buttons.first).form

    parse(confirm_form.submit(confirm_form.buttons.first))
    
    possible_commands = commands.select do |command|
      command.target.x == target.x && command.target.y == target.y && !command.returning
    end

    (possible_commands.sort { |a, b| a.occurence <=> b.occurence }).last
  end

  def has_command village
    commands.select{|a| village == a.target && !a.returning }.first
  end

end