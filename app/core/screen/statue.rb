class Screen::Statue < Screen::Basic

  attr_accessor :paladin_information

  url screen: 'statue'

  def start_train(village_id)

  	url = "https://#{User.current.world}.tribalwars.com.br/game.php?village=#{village_id}&screen=statue&ajaxaction=regimen&h=#{@csrf_token}&client_time=#{client_time}"
  	parse(client.get(url))
    # POST
	# knight:33383
	# regimen:36
	# cheap:0
    binding.pry
  end

end