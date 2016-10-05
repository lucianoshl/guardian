class Task::AutoRecruit < Task::Abstract
	
  	performs_to 1.hour

	def run
		Village.my.map do |village|
			recruit(village)
		end
	end

	def recruit village
		# return
		train_time = self.class._performs_to
		train_until = Time.zone.now + train_time

		train_screen = Screen::Train.new(id: village.vid)

		half_storage = (Screen::Train.new.storage_size * 0.5).ceil

		limit_resources = Resource.new(wood: half_storage, stone: half_storage, iron: half_storage)


		complete_units = {}
		train_screen.production_units.values.map{|a| complete_units.merge!(a)}
		complete_units = Troop.new(train_screen.total_units) + Troop.new(complete_units)

		train_config = Troop.new(light: 1000, axe: 5000,ram: 100)

		to_train = (train_config - complete_units).remove_negative

		target_buildings = train_screen.release_time.to_a.select{|a| a[1] < train_until }.map(&:first)

		to_train_in_time = Troop.new

		target_buildings.map do |building|
			seconds_to_train = train_until - train_screen.release_time[building]
			building_to_train = to_train.from_building(building)
			building_to_train.to_h.map do |unit,qte|
				next if (train_screen.train_info[unit].nil?)
				train_seconds = train_screen.train_info[unit]["build_time"]
				while (seconds_to_train > 0 && qte > 0) 
					to_train_in_time[unit] += 1
					seconds_to_train -= train_seconds
					qte -= 1
				end
			end
		end

		train_times = {}
		target_buildings.map {|a| train_times[a] = 0}

		if (!two_itens_in_build_queue?(village))
			resources = train_screen.resources - limit_resources
		else
			resources = train_screen.resources
		end

		return if (resources.has_negative?)

		real_train = Troop.new
		to_train_in_time = to_train_in_time.to_h

		loop do 
			Rails.logger.info("Test recruit #{real_train.to_h}")
			enter = false
			to_train_in_time.map do |unit,qte|
				next if (train_screen.train_info[unit].nil?)

				building,current_time = train_times.to_a.min {|a,b| a[1] <=> b[1]}
				cost = train_screen.train_info[unit].to_resource
				if (qte > 0 && Troop.from_building?(building,unit) && resources.include?(cost))
					# binding.pry
					build_time = train_screen.train_info[unit]["build_time"]
					to_train_in_time[unit] -= 1
					real_train[unit] += 1
					train_times[building] += build_time
					resources -= cost
					enter = true
				end
			end
			break if (!enter)
		end

		train_screen.train(real_train)
	end

	def two_itens_in_build_queue?(village)
		main_screen = Screen::Main.new(id: village.vid)
		main_screen.queue.size >= 2
	end

end
