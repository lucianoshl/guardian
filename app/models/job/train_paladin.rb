class Job::TrainPaladin < Job::Abstract

	def execute
		logger = Rails.logger
		statue = Screen::Statue.new

		times = []

		logger.info('Paladin train: start')
		statue.paladin_information do |village_id,statue|
			logger.info("Village=#{village_id} in_training=#{statue.in_training}")
			if (statue.in_training)
				times << statue.training_finish_time
				logger.info("times=#{times}")
				next
			end

			if statue.resources.include?(statue.train_cost * 10)
				statue.start_train(village_id)
			else
				logger.info("times=#{times}")
				times << Time.zone.now + 3.hours
			end

		end
		logger.info('Paladin train: end. times=#{times}')

		binding.pry


	end

end