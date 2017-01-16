class Screen::Basic < Screen::Logged

  attr_accessor :village,:player_id,:logout_url,:resources,:storage_size,:websocket_config,:gamejs_path,:csrf_token,:incomings,:farm_alert,:storage_alert,:current_event,:current_population,:free_population,
  :building_levels

  def logout
    _request(:get,"https://#{User.current.world}.tribalwars.com.br#{logout_url}")
  end

  def client_time
    Time.zone.now.to_i * 1000
  end
  
end
