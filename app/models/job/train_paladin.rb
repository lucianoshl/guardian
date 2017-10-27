class Job::TrainPaladin < Job::Abstract

	def execute
		logger = Rails.logger
		statue_screen = Screen::Statue.new

		times = []

		logger.info('Paladin train: start')
		statue_screen.paladin_information.map do |knight_id,statue|
			village_id = statue.village_id
			logger.info("Village=#{village_id} in_training=#{statue.in_training}")
			if (statue.in_training)
				times << statue.training_finish_time
				logger.info("times=#{times}")
				next
			end

			main_screen = Screen::Main.new(village: village_id )
			if main_screen.resources.include?(statue.cost * 10)
				statue_screen.start_train(village_id,knight_id)
			else
				logger.info("times=#{times}")
				times << Time.zone.now + 3.hours
			end

		end
		logger.info("Paladin train: end. times=#{times}")

		return times.sort.first
	end

end