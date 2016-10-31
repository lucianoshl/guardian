class Job::SendAttack < Job::Abstract

	queue :high_priority

	field :event_time, type: DateTime

	embeds_one :troop, class_name: Troop.to_s
	accepts_nested_attributes_for :troop

	field :coordinate, type: String
	
	belongs_to :origin, class_name: Village.to_s


	def calc_send_time
		travel_time = troop.travel_time(origin,coordinate.to_coordinate)
		event_time - travel_time
	end

	def execute
		before_time = 30.seconds

		send_time = calc_send_time

		if ((send_time - before_time) <= Time.zone.now)
			Screen::Place.new(village: origin.vid).send_attack(coordinate.to_coordinate,troop)
			binding.pry
		else
			return send_time - before_time
		end
	end

end