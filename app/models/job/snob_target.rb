class Job::SnobTarget < Job::Abstract

	queue :high_priority

	field :x, type: Integer
	field :y, type: Integer

	def execute
		target = Village.where(x:x,y:y).first

		troops_to_destroy = target.last_report.target_troops

		atks_village = Model::Village.where(name: 'ATAQUE').first.villages.map(&:vid)

		my_troops = atks_village.map { |vid| Screen::Place.new(village: vid) }

		fulls = my_troops.select { |p| u = p.units; u.population > 18000 && u.axe > 4000 && u.light > 2000 }

		binding.pry
	end

end