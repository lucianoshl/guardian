if (Unit.count.zero?)
	screen = Screen::Overview.new
	raw_screen = screen.request(screen.gen_url())
	json = JSON.parse(raw_screen.body.scan(/UnitPopup.unit_data = ({.*})/).first.first)

	json.map do |key,value|
		unit = Unit.new
		unit.label = value["name"]
		unit.name = key
		unit.type = value["type"]
		unit.carry = value["carry"] 
		unit.attack = value["attack"] 
		unit.speed = value["speed"] 
		unit.save
	end
end


# if (!User.first.nil?)
# 	binding.pry
# end