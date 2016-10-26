class Job::SendAttack < Job::Abstract

	queue :high_priority

	field :event_time, type: DateTime

	embeds_one :troop, class_name: Troop.to_s
	accepts_nested_attributes_for :troop

	field :coordinate, type: String

	def execute
		(1..10).to_a.map do 
			Rails.logger.info("sleeping #{event_time} #{troop} #{coordinate} #{priority}")
			sleep(1)
		end
		return Time.zone.now + 1.minute
	end

end