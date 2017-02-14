class Job::SnobTarget < Job::Abstract

	queue :high_priority

	field :x, type: Integer
	field :y, type: Integer

	def execute
		# target = Village.where(x:x,y:y).first

		# troops_to_destroy = target.last_report.target_troops

		# atks_village = Model::Village.where(name: 'ATAQUE').first.villages.map(&:vid)

		# my_troops = atks_village.map { |vid| Screen::Place.new(village: vid) }

		# fulls = my_troops.select { |p| u = p.units; u.population > 18000 && u.axe > 4000 && u.light > 2000 }


		# event = Time.now.at_beginning_of_day + 8.hours + 10.minutes
		# atks = fulls.map do |place|
		# 	item = Job::SendAttack.new()
		# 	item.origin = "#{place.village.x}|#{place.village.y}"
		# 	item.troop = Troop.new
		# 	item.troop.axe = -1 if (place.units.axe > 0)
		# 	item.troop.light = -1 if (place.units.axe > 0)
		# 	item.troop.ram = -1 if (place.units.ram > 0)
		# 	item.troop.spy = 5 if (place.units.axe > 5)

		# 	aux = item.troop.clone
		# 	aux.my_fields.map do |field|
		# 		aux[field] = 1 if (aux[field] != 0)
		# 	end

		# 	travel_time = aux.travel_time(place.village,target)
		# 	arrival_time = Time.zone.now + travel_time + 2.minutes

		# 	if (travel_time > 5.hours)
		# 		raise Exception.new

		# 	if ( arrival_time > event)
		# 		item.event_time = arrival_time
		# 	else 
		# 		item.event_time = event
		# 	end

		# 	item.coordinate = '406|423'
		# 	item
		# end

		# binding.pry


		# binding.pry
	end

end