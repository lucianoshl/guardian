class Job::SendAttack < Job::Abstract

	queue :high_priority

	def execute
		(1..10).to_a.map do 
			Rails.logger.info("sleeping")
			sleep(1)
		end
		return Time.zone.now + 1.minute
	end

end