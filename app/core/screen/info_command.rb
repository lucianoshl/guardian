class Screen::InfoCommand < Screen::Basic

  attr_accessor :target,:origin

  url screen: 'info_command'

  cache 1.year

end