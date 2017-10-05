Rails.logger.level = 0

def validate_end(variables)
	invalid_config = variables.select{ |a| !ENV[a].nil? }.empty?
	if (invalid_config)
		msg = 'As seguintes variaveis estão incompletas:'
		variables.map do |variable|
			msg += "\n #{variable}=#{ENV[variable]}"
		end
		Rails.logger.error(msg)
		raise Exception.new(msg)
	end
end


validate_end ['MONGO_URL']
validate_end ['TW_WORLD']
validate_end ['TW_USER']
validate_end ['TW_PASS']

if User.first.nil?
	User.new(world: ENV['TW_WORLD'],name: ENV['TW_USER'],password: ENV['TW_PASS']).save
end
