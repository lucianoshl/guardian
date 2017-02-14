class Job::SendAttack < Job::Abstract

	queue :high_priority

	field :event_time, type: DateTime

	embeds_one :troop, class_name: Troop.to_s
	accepts_nested_attributes_for :troop

	field :coordinate, type: String

	field :origin, type: String

	validate :check_in_time

	@@before_time = 1.minute

	def check_in_time
		send_time = calc_send_time
		if (send_time < Time.zone.now + @@before_time)
			errors.add(origin,"Não da tempo do ataque chegar")
			return true
		end
		return false
	end

	def calc_send_time
		aux = troop.clone
		aux.my_fields.map do |field|
			aux[field] = 1 if (aux[field] != 0)
		end
		travel_time = aux.travel_time(Village.where(origin.to_coordinate.to_h).first,coordinate.to_coordinate)
		event_time - travel_time
	end

	def execute

		before_time = @@before_time

		send_time = calc_send_time

		puts "Enviar ataque em #{send_time}"

		if ((send_time - before_time) <= Time.zone.now)

			place_screen = Screen::Place.new(village: Village.where(origin.to_coordinate.to_h).first.vid)

			real_troop = define_troops(troop,place_screen)

			if (real_troop.snob <= 1)
				splited_commands = [real_troop]
			else
				splited_commands = split(real_troop,place_screen)
			end

			form = place_screen.send_command_form(coordinate.to_coordinate,splited_commands.first,'attack',true)

			troops_fields = troop.my_fields - ['militia']

			splited_commands.each_with_index do |troops,index|
				if (index == 0)
					troops_fields.map do |field|
						form[field] = troops[field]
					end
				else
					troops_fields.map do |field|
						form["train[#{index}][#{field}]"]= troops[field]
					end
				end
			end


			puts "Enviar ataque em #{send_time} agora são #{Time.zone.now}"
			while !(send_time <= Time.zone.now)
				puts "waiting chegar em #{send_time} agora são #{Time.zone.now}"
				sleep(0.1)
			end
			page = form.submit(form.buttons.first)
			return remove_job
		else
			return send_time - before_time
		end
	end

	def define_troops(original,place_screen)
		result = Troop.new
		original.to_h.map do |unit,qte|
			result[unit] = original[unit] < 0 ? place_screen.units[unit] : original[unit]
		end
		return result
	end

	def split(troops,place_screen)
		result = []
		aux = troops.clone

		min_population = calc_min_population(place_screen)

		(1..troops.snob).map do |index|
			if (index == 1)
				aux.snob = 1
				result << aux
			else
				aux.axe -= min_population
				result << Troop.new(axe: min_population - 100,snob: 1)
			end
			
		end

		return result
	end

	def calc_min_population(place_screen)
		aux = place_screen.units.clone
		aux.spy = 0
		aux.knight = 0 
		troop_hash = {}
		troop_hash[aux.fastest_unit.name] = 1
		begin
			command = place_screen.send_attack(self.coordinate.to_coordinate,Troop.new(troop_hash),true)
		rescue NeedsMorePopulationException => exception
			return exception.population
    	end
    	binding.pry
	end

	def origin_enum
		villages = Village.my.all
		villages.map {|a| ["#{a.significant_name} #{a.x}|#{a.y}","#{a.x}|#{a.y}"]}
	end

end