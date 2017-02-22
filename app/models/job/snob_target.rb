class Job::SnobTarget < Job::Abstract

	queue :high_priority

	field :coordinate, type: String

	def execute
		x,y = self.coordinate.split('|').map(&:to_i)
		target = Village.where(x:x,y:y).first
		report = target.last_report
		troops_to_destroy = report.target_troops

		to_remove = Job::SendAttack.all.map{|a| c = OpenStruct.new;  c.x,c.y = a.origin.split('|').map(&:to_i) ; Village.where(c).first}


		atks_village = Model::Village.where(name: 'ATAQUE').first.villages.where(use_in_pillage: false).map(&:vid)

		my_troops = atks_village.pmap { |vid| Screen::Place.new(village: vid) }

		fulls = my_troops.select { |p| u = p.units; u.population > 18000 && u.axe > 4000 && u.light > 2000 }

		fulls = fulls.select { |p| !to_remove.include?(p.village) }

		


		fulls = fulls.sort{|a,b| a.village.distance(target) <=> b.village.distance(target) }

		fulls_to_send = []

		fulls.map do |full|

			to_send = OpenStruct.new
			to_send.troop = Troop.new
			to_send.troop.axe = full.units.axe
			to_send.troop.light = full.units.light
			to_send.troop.ram = full.units.ram
			to_send.troop.spy = 5 if (full.units.spy >= 5)
			to_send.place = full

			simulator_result = Screen::Simulator.simulate(to_send.troop,troops_to_destroy,report.moral,report.wall)

			troops_to_destroy = simulator_result.defs_remaining
			break if (simulator_result.losses.total==0) 
			fulls_to_send << to_send
		end

		minimal_population = calculate_minimal_population(target,fulls) - 100

		snobs_qte = 5

		snobs = my_troops.select { |p| u = p.units; u.snob >= snobs_qte && u.axe >= snobs_qte * minimal_population }

		snobs = snobs - fulls_to_send.map(&:place)
		snobs = snobs.sort{|a,b| a.village.distance(target) <=> b.village.distance(target) }

		snobs = snobs.select { |p| !to_remove.include?(p.village) }

		binding.pry

		send_snob = snobs.first
		minimal_population = calculate_minimal_population(target,[send_snob]) - 100
		to_send = OpenStruct.new
		to_send.troop = Troop.new
		to_send.troop.axe = snobs_qte * minimal_population
		to_send.troop.snob = snobs_qte
		to_send.troop.spy = 5 if (send_snob.units.spy >= 5)
		to_send.place = send_snob 
		fulls_to_send << to_send

		far = (fulls_to_send.sort do |b,a| 
			a.troop.travel_time(a.place.village,target) <=> b.troop.travel_time(b.place.village,target)
		end).first

		attack_time = Time.zone.now + far.troop.travel_time(far.place.village,target)

	 	night = attack_time < attack_time.at_beginning_of_day + 8.hours && attack_time > attack_time.at_beginning_of_day

	 	if (night)
	 		attack_time = attack_time.at_beginning_of_day + 8.hours
	 	end

	 	attack_time += 5.minutes + 10.seconds

		atks = fulls_to_send.map do |command|
			place = command.place
			item = Job::SendAttack.new()
			item.origin = "#{place.village.x}|#{place.village.y}"
			item.troop = command.troop

			if (item.troop.snob > 0)
				item.event_time = attack_time + 1.second
			else
				item.event_time = attack_time
			end

			item.coordinate = "#{target.x}|#{target.y}"
			item
		end

		# atks.map(&:valid?)
		# atks.map(&:save)
		binding.pry


		# binding.pry
	end

	def calculate_minimal_population(target,fulls)
		if (target.player.nil?)
			return 200
		end 

		atk_origin = fulls.sort{|b,a| a.village.points <=> b.village.points}.first
		begin
			unit = fulls.first.units.to_h.select{|a,v| v>0}.first.first
			troops = Troop.new
			troops[unit] = 1
			command = atk_origin.send_attack(target,troops,true)
		rescue NeedsMorePopulationException => exception
			return exception.population
    	end
	end

end