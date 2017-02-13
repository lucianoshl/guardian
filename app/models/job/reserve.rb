class Job::Reserve < Job::Abstract

	queue :high_priority

	field :x, type: Integer
	field :y, type: Integer

	field :targets

	# def initialize *args
	# 	if (args.size == 1)
	# 		arg = args.first
	# 		if (arg.class == String)
	# 			x,y = arg.split('|').map(&:to_i)
	# 			super(x: x, y: y)
	# 		elsif (arg.class == Fixnum) 
	# 			arg = Village.where(vid: arg).first
	# 			super(x: arg.x, y: arg.y) 
	# 		elsif (arg.class == Village)
	# 			super(x: arg.x, y: arg.y)
	# 		elsif (arg.class == BSON::ObjectId)
	# 			arg = Village.where(id: arg).first
	# 			super(x: arg.x, y: arg.y) 
	# 		end
	# 	elsif (args.size == 2)
	# 		super(x: args[0], y: args[1])
	# 	end
	# end

	def execute
		screen = Screen::Reservations.new

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