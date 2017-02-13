class Job::Reserve < Job::Abstract

	queue :high_priority

	field :x, type: Integer
	field :y, type: Integer

	field :targets

	belongs_to :target

	def execute
		screen = Screen::Reservations.new

		

		if (!targets.blank?)
			villages = []
			possible_players = []
			targets.split(/ /).each do |content|
				coordinates = content.scan(/\d{3}\|\d{3}/)
				if (coordinates.empty?)
					possible_players << content
				else
					villages << coordinates.first
				end
			end
			possible_players = possible_players.uniq
			villages = villages.uniq

			players = Player.in(name: possible_players)

			binding.pry
		end

		binding.pry


		if (x == nil && y == nil)
			coordinates = (targets.split(' ').map do |target|
				player = Player.where(name: target).first
				player.villages
			end).flatten

			village = coordinates.shift
			self.x = village.x
			self.y = village.y

			coordinates = coordinates.map do |village|
				coords = { x: village.x, y: village.y }
				if (Job::Reserve.where(coords).first.nil?)
					Job::Reserve.new(coords)
				else
					nil
				end
			end
			coordinates.unshift(self)

			coordinates.compact.map(&:save)
			return Time.zone.now
		end

		

		reserve = screen.search_reserve(x,y)
		if (reserve.nil?)
			screen.do_reserve(OpenStruct.new(x: x, y: y))
			return remove_job
		else
			return reserve.expiration_time
		end
	end

end