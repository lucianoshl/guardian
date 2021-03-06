class Screen::EventAssault < Screen::Basic

  attr_accessor :mercenaries_amount,:next_free_mercenary,:json,:enabled

  url screen: 'event_assault'

  def best_event
  	json.first["areas"].map{|k,v| [k,v["progress"]/v["target"].to_f] }.sort{|b,a| a[1] <=> b[1]}.first.first
  end

  def put_mercenary(event)
  	parameters = {area: event}

  	result = client.post("https://#{ENV['TW_WORLD']}.tribalwars.com.br/game.php?screen=event_assault&ajaxaction=reinforce&h=#{csrf_token}&client_time=#{client_time}",parameters)
  end

end