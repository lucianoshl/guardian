class Parser::EventAssault < Parser::Basic

  def parse screen
  	super
    screen.enabled = @page.search('.event-action-button').size > 0

  	json = screen.json = JSON.parse "[#{@page.body.scan(/EventAssault.init\(({.*})\)/).first.first}]"
  	energy = json[1]["energy"]

  	raw_energy = [energy["max"], energy["current"] + (Time.zone.now.to_i  - energy["last"].to_f) / energy["interval"]].min

  	screen.mercenaries_amount = raw_energy.floor

  	seconds_to_next_free_mercenary = energy["interval"] * (1 - (raw_energy % 1)) + 1

  	screen.next_free_mercenary = Time.zone.now + seconds_to_next_free_mercenary.seconds + 1.second
  	
  end

end