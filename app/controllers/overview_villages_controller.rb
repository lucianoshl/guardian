class OverviewVillagesController < InjectedController

	def resources
  	# binding.pry
	end


  def troops
  	@villages = Village.my.sort{|a,b| a.significant_name <=> b.significant_name }
	@places = {}
	Parallel.map(@villages, in_threads: 1 ) do |village|
		@places[village.vid] = Screen::Place.new(village: village.vid)
	end
  end

end
