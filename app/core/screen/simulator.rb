class Screen::Simulator < Screen::Basic

	attr_accessor :losses,:has_losses,:form,:defs,:defs_losses,:defs_remaining

	url	screen: 'place', mode: 'sim', simulate: nil

	cache 1.year

	def self.simulate(attack,defs,moral,wall)

	    parameters = {}
	    parameters[:luck] = '-25'
	    parameters[:def_wall] = wall.nil? ? 20 : wall
	    parameters[:moral] = moral

	    attack.to_h.each do |unit, qte|
	      parameters["att_#{unit}"] = qte.to_s
	    end

	    defs.to_h.each do |unit, qte|
	      parameters["def_#{unit}"] = qte.to_s
	    end
	    
		Screen::Simulator.new(parameters)
	end

end