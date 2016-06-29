class Screen::InfoVillage < Screen::Guest
  
  attr_accessor :village
  endpoint '/guest.php'
  url screen: 'info_village'

end