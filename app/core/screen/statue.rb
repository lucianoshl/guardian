class Screen::Statue < Screen::Basic

  attr_accessor :paladin_information

  url screen: 'statue'

  def start_train(village_id)
    # https://br84.tribalwars.com.br/game.php?village=38152&screen=statue&ajaxaction=regimen&h=41acb9ed&client_time=1508973846
    binding.pry
  end

end