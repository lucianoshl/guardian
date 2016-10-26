class Job::SendAttack < Job::Abstract

	queue :high_priority

	field :event_time, type: DateTime

	embeds_one :troop, class_name: Troop.to_s

	def execute
		(1..10).to_a.map do 
			Rails.logger.info("sleeping #{event_time} #{troop}")
			sleep(1)
		end
		return Time.zone.now + 1.minute
	end

end