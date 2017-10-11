# http://br3.tribalwars.com.br/popup_building.php?building=stable

class Utils::Population

	def self.calc(building_name,level)
		return Rails.cache.fetch("population_cost_#{building_name}") do 
			Metadata::Building.where(name: building_name).first.population_cost(level)
		end
	end

	def self.from_config(model)

		population = 0
		model.my_fields.each do |field|
			population += calc(field,model[field])
		end

		return population
	end
end