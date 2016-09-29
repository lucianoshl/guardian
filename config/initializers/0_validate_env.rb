Rails.logger.level = 0

variables = ['MONGO_URL','HEROKU_KEY','TW_USER','TW_PASSWORD','TW_WORLD']
invalid_config = variables.select{ |a| !ENV[a].nil? }.empty?
if (invalid_config)
	msg = 'As seguintes variaveis estão incompletas:'
	variables.map do |variable|
		msg += "\n #{variable}=#{ENV[variable]}"
	end
	Rails.logger.error(msg)
	raise Exception.new(msg)
end