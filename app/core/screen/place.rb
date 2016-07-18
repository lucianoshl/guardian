class NewbieProtectionException < Exception
  attr_accessor :expires

  def initialize date
    self.expires = date
  end
end

class SharedConectionException < Exception
end

class BannedUserException < Exception
end

class DeletedPlayerException < Exception
end

class InvitedPlayerException < Exception
  attr_accessor :expires

  def initialize date
    self.expires = date
  end
end

class NeedsMorePopulationException < Exception
  attr_accessor :population

  def initialize population
    self.population = population
  end
end

class PartnerAttackingException < Exception
  attr_accessor :release

  def initialize date
    self.release = date
  end
end



class Screen::Place < Screen::Basic

  attr_accessor :units,:commands,:incomings,:supports,:form,:unit_metadata

  url screen: 'place'  

  def send_attack target,troops
    return send_command(target,troops,'attack')
  end

  def send_support target,troops
    return send_command(target,troops,'support')
  end

  def send_command(target,troops,type)

    partner_time = Partner.is_attacking?(target)

    if (!partner_time.nil?)
      raise PartnerAttackingException.new(partner_time)
    end

    troops.spy ||= 0

    troops.spy ||= 4 if ((self.units.spy - troops.spy) >= 4)

    form.fill(troops.instance_values)
    form.fill(x: target.x , y: target.y)

    if ('attack' == type)
      button = form.buttons.first
    else
      button = form.buttons.last
    end

    confirm_page = form.submit(button)
    check_attack_error(confirm_page)

    confirm_form = confirm_page.form
    
    parse(confirm_form.submit(confirm_form.buttons.first))

    possible_commands = self.commands.select do |command|
      command.target.x == target.x && command.target.y == target.y && !command.returning
    end

    (possible_commands.sort { |a, b| a.occurence <=> b.occurence }).last
  end

  def check_attack_error confirm_page
    error = confirm_page.search('.error_box')
    return if error.empty?
    msg = error.text.strip

    return if msg.empty?

    if (!msg.match(/A proteção termina /).nil?)
      raise NewbieProtectionException.new(msg.scan(/termina (.*)\./).first.first.parse_datetime)
    end

    if (!msg.match(/contra o mesmo alvo/).nil?)
      raise SharedConectionException.new
    end

    if (!msg.match(/jogador foi banido/).nil?)
      raise BannedUserException.new
    end

    if (!msg.match(/Alvo não existe/).nil?)
      raise DeletedPlayerException.new
    end

    if (!msg.match(/convidou o proprie/).nil?)
      # free_date = msg.scan(/até (.+), pois/).first.first.parse_datetime
      raise InvitedPlayerException.new(Time.zone.now + 1.day)
    end

    if (!msg.match(/A força de ataque precisa/).nil?)
      min_pop = msg.scan(/de (\d+) hab/).first.first.extract_number
      raise NeedsMorePopulationException.new(min_pop)
    end

    
    
    raise Exception.new(msg)
    
  end

  def has_command village
    commands.select{|a| village == a.target && !a.returning }.first
  end

end