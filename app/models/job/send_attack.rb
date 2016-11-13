class Job::SendAttack < Job::Abstract

	queue :high_priority

	field :event_time, type: DateTime

	embeds_one :troop, class_name: Troop.to_s
	accepts_nested_attributes_for :troop

	field :coordinate, type: String
	
	belongs_to :origin, class_name: Village.to_s

	validate :check_in_time

	def check_in_time
		binding.pry
	end

	def calc_send_time
		travel_time = troop.travel_time(origin,coordinate.to_coordinate)
		event_time - travel_time
	end

	def execute
		before_time = 5.seconds

		send_time = calc_send_time

		puts "Enviar ataque em #{send_time}"
		form = Screen::Place.new(village: origin.vid).send_command_form(coordinate.to_coordinate,troop,'attack')

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

end