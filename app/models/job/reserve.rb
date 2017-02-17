class Job::Reserve < Job::Abstract

	queue :high_priority

	field :x, type: Integer
	field :y, type: Integer

	field :player, type: String

	field :targets

	def execute
		screen = Screen::Reservations.new

		if (!targets.blank?)
			villages = []
			possible_players = [targets]
			# targets.split(/ /).each do |content|
			# 	coordinates = content.scan(/\d{3}\|\d{3}/)
			# 	if (coordinates.empty?)
			# 		possible_players << content
			# 	else
			# 		villages << coordinates.first
			# 	end
			# end
			# possible_players = possible_players.uniq
			# villages = villages.uniq

			# villages = villages.map {|c| x,y = c.split('|'); OpenStruct.new(x:x,y:y)}
			
			Player.in(name: possible_players).map do |player|
				villages = villages.concat(player.villages)
			end

			village = villages.shift
			self.x = village.x
			self.y = village.y
			self.targets = nil

			jobs = villages.map do |village|
				coords = { x: village.x, y: village.y }
				if (Job::Reserve.where(coords).first.nil?)
					Job::Reserve.new(coords)
				else
					nil
				end
			end

			jobs.unshift(self)
			jobs.compact.map(&:save)

			return Time.zone.now

		end

		self.player = JSON.parse(screen.client.get("/game.php?screen=api&ajax=target_selection&input=#{x}%7C#{y})&type=coord").body)["villages"].first['player_name'] || "Barbaro" if (self.player.nil?)
		self.save

		reserve = screen.search_reserve(x,y)
		if (reserve.nil?)
			screen.do_reserve(OpenStruct.new(x: x, y: y))
			return remove_job
		else
			return reserve.expiration_time
		end
	end

end