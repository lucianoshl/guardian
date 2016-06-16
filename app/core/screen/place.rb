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

class PartnerAttackingException < Exception
  attr_accessor :release

  def initialize date
    self.release = date
  end
end



class Screen::Place < Screen::Basic

  attr_accessor :units,:commands,:incomings,:form,:unit_metadata

  url screen: 'place'  

  def send_attack origin,target,troops

    partner_time = Partner.is_attacking?(target)

    if (!partner_time.nil?)
      raise PartnerAttackingException.new(partner_time)
    end

    troops.spy ||= 4 if (self.units.spy >= 4)

    form.fill(troops.instance_values)
    form.fill(x: target.x , y: target.y)

    confirm_page = form.submit(form.buttons.first)
    check_attack_error(confirm_page)
    confirm_form = confirm_page.form
    
    parse(confirm_form.submit(confirm_form.buttons.first))
    
    possible_commands = commands.select do |command|
      command.target.x == target.x && command.target.y == target.y && !command.returning
    end

    (possible_commands.sort { |a, b| a.occurence <=> b.occurence }).last
  end

  def check_attack_error confirm_page
    error = confirm_page.search('.error_box')
    return if error.empty?
    msg = error.text.strip
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

    

    

    raise Exception.new(msg)
    
  end

  def has_command village
    commands.select{|a| village == a.target && !a.returning }.first
  end

end