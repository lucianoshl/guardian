class Job::SendAttack < Job::Abstract

	queue :high_priority

	field :event_time, type: DateTime

	embeds_one :troop, class_name: Troop.to_s
	accepts_nested_attributes_for :troop

	field :coordinate, type: String

	field :origin, type: String

	validate :check_in_time

	def check_in_time
		send_time = calc_send_time
		if (send_time < Time.zone.now + 10.seconds)
			errors.add(origin,"Não da tempo do ataque chegar")
			return true
		end
		return false
	end

	def calc_send_time
		travel_time = troop.travel_time(Village.where(origin.to_coordinate.to_h).first,coordinate.to_coordinate)
		event_time - travel_time
	end

	def execute
		# return remove_job if 

		before_time = 5.seconds

		send_time = calc_send_time

		puts "Enviar ataque em #{send_time}"
		form = Screen::Place.new(village: Village.where(origin.to_coordinate.to_h).first.vid).send_command_form(coordinate.to_coordinate,troop,'attack',true)

		if ((send_time - before_time) <= Time.zone.now)
			puts "Enviar ataque em #{send_time} agora são #{Time.zone.now}"
			while !(send_time <= Time.zone.now)
				puts "waiting chegar em #{send_time} agora são #{Time.zone.now}"
				sleep(0.1)
			end
			form.submit(form.buttons.first)
		else
			return send_time - before_time
		end
	end

	def origin_enum
		villages = Village.my.all
		villages.map {|a| "#{a.x}|#{a.y}"}
	end

end