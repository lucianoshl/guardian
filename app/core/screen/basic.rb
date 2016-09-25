class Screen::Basic < Screen::Logged

  attr_accessor :village,:player_id,:logout_url,:resources,:storage_size,:websocket_config,:gamejs_path,:csrf_token

  def logout
    _request(:get,"https://#{User.current.world}.tribalwars.com.br#{logout_url}")
  end
  
end