class Screen::Simulator < Screen::Basic

	attr_accessor :losses,:has_losses

	url	screen: 'place', mode: 'sim', simulate: nil

  cache 1.year

end