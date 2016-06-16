class Screen::Basic < Screen::Logged

  attr_accessor :player_id,:logout_url

  def logout
    _request(:get,"https://#{User.current.world}.tribalwars.com.br#{logout_url}")
  end
  
end