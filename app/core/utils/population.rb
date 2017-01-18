# http://br3.tribalwars.com.br/popup_building.php?building=stable

class Population

	def self.calc(building,level)
		values = Rails.cache.fetch("population_cost_#{building}") do 
			mechanize = Mechanize.new
			page = mechanize.get("http://br3.tribalwars.com.br/popup_building.php?building=#{building}")
			result = {}
			page.search('img[src*=holz]').each do |item|
				elements = item.parents(2)
				level = elements.search('td')[0].text.to_i
				pop = elements.search('td')[2].text.split('/').last.strip.to_i
				result[level] = pop
			end
			result[0] = 0
			result
		end

		return values[level]
	end

	def self.from_config(model)
		max_values = Model::Buildings.new

		config = model.priorities
		config << model.buildings
		config.each do |config|
			config.my_fields.each do |field|
				if (config[field] > max_values[field])
					max_values[field] = config[field]
				end
			end
		end

		population = 0
		max_values.my_fields.each do |field|
			population += calc(field,max_values[field])
		end

		return population
	end
end