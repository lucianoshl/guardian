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

  @@places = {}

  attr_accessor :units,:free_units,:commands,:incomings,:supports,:form,:unit_metadata

  url screen: 'place'  

  def send_attack target,troops,ignore_partner=false
    return send_command(target,troops,'attack',ignore_partner)
  end

  def send_support target,troops
    return send_command(target,troops,'support')
  end

  def send_command(target,troops,type,ignore_partner=false)

    confirm_form = send_command_form(target,troops,type,ignore_partner)
    page = confirm_form.submit(confirm_form.buttons.first)

    parse(page)

    possible_commands = self.commands.select do |command|
            !command.returning && !command.target.nil? && 
       command.target.x == target.x && command.target.y == target.y
    end

    (possible_commands.sort { |a, b| a.occurence <=> b.occurence }).last
  end

  def send_command_form(target,troops,type,ignore_partner=false)
    if (!ignore_partner)
      partner_time = Partner.is_attacking?(target)

      if (!partner_time.nil?)
        target.increase_limited_by_partner
        raise PartnerAttackingException.new(partner_time)
      end
    end

    my_ally = User.current.player.ally

    if (!my_ally.nil? && !target.vid.nil?) 
      village_info = Screen::InfoVillage.new(id: target.vid)
      if (!village_info.village.player_id.nil?)
        player_info = Screen::InfoPlayer.new(id: village_info.village.player_id)
        if (!player_info.ally_id.nil? && my_ally.aid == player_info.ally_id) 
          msg = "Estou tentando atacar o player #{village_info.village.player_id} mas ele é da ally #{player_info.ally_id} e eu sou da ally #{my_ally.aid}"
          Rails.logger.error(msg)
          raise Exception.new(msg)
          binding.pry
        end
      end
    end

    target.reset_partner_count
    spies = Screen::Place.spy_qte(target)

    if (troops.spy.nil? || troops.spy.zero?)
      troops.spy = self.free_units.spy >= spies ? spies : 0
    end

    form.fill(troops.to_h)
    form.fill(x: target.x , y: target.y)

    if ('attack' == type)
      button = form.buttons.first
    else
      button = form.buttons.last
    end

    confirm_page = form.submit(button)
    check_attack_error(confirm_page)
    confirm_form = confirm_page.form
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

  def self.spy_qte(target)
  	target.player_id.nil? ? 1 : 5
  end

  def self.get(vid)
    if (@@places[vid].nil?)
      @@places[vid] = Screen::Place.new(village: vid)
    end

    @@places[vid].free_units.knight = 0

    return @@places[vid]
  end

  def self.load_all
    Village.my.map{|v| Screen::Place.new(village: v.vid) }
  end

  def self.all
    @@places.values
  end

  def self.reset
    @@places = {}
  end

end
