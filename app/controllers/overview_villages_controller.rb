class OverviewVillagesController < InjectedController

  def resources
  end 

  def commands
    @places = Village.my.pmap{|a| Screen::Place.new(village: a.vid) }
    # @commands = @place.map {|a| a.commands }.flatten
    # binding.pry
  end

  def troops
    @villages = Village.my.sort{|a,b| a.significant_name <=> b.significant_name }
    @train = {}
    @snob = {}
    @units = {}
    Parallel.map(@villages, in_threads: 1 ) do |village|
      @train[village.vid] = Screen::Train.new(village: village.vid)
      @snob[village.vid] = Screen::Snob.new(village: village.vid)
      @units[village.vid] = Troop.new(@train[village.vid].total_units)
      @units[village.vid].snob = @snob[village.vid].total_snob
    end
  end

  def place
    @villages = Village.my.sort{|a,b| a.significant_name <=> b.significant_name }
    @places = {}
    Parallel.map(@villages, in_threads: 1 ) do |village|
      @places[village.vid] = Screen::Place.new(village: village.vid)
    end
  end

end
