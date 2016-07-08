class Screen::WorldConfig < Screen::Anonymous

  attr_accessor :units

  url mode: 'settings'

  endpoint '/stat.php'

end