class Screen::Place < Screen::Logged

  attr_accessor :units,:commands,:incomings,:form,:unit_metadata

  url screen: 'place'  

  def send_attack origin,target,troops

    # parameters = {}

    form.fill(troops.instance_values)
    form.fill(x: target.x , y: target.y)

    confirm_form = form.submit(form.buttons.first).form

    parse(confirm_form.submit(confirm_form.buttons.first))

    binding.pry

    confirm_page_form = fill_form(Loader.submit(form).form,target)

    place = Loader.submit(confirm_page_form)
    if (place.class == Screen::PlaceConfirm)
      if (!place.newbie_protection.nil?) 
        raise NewbieProtectionException.new(place.newbie_protection)
      end

      if (place.needs_more_pop)
        raise InsufficientPopulationInCommandException.new
      end
      binding.pry
    end
    commands = place.commands.select do |command|
      command.target.x == target.x && command.target.y == target.y && !command.returning
    end

    command = (commands.sort { |a, b| a.occurence <=> b.occurence }).last
    command
  end

end