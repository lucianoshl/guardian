class Screen::InfoPlayer < Screen::Guest
  
  attr_accessor :avatar_url,:ally_id
  endpoint '/guest.php'
  url screen: 'info_player'

end