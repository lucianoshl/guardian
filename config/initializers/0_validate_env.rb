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
