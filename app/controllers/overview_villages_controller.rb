class OverviewVillagesController < InjectedController

  def resources
  end

  def commands
    # @places = Village.my.pmap{|a| Screen::Place.new(village: a.vid) }
    # @commands = @place.map {|a| a.commands }.flatten
    # binding.pry
  end

  def troops
    @villages = Village.my.sort { |a, b| a.significant_name <=> b.significant_name }
    @train = {}
    @snob = {}
    @units = {}
    Parallel.map(@villages, in_threads: 1) do |village|
      @train[village.vid] = Screen::Train.new(village: village.vid)
      @snob[village.vid] = Screen::Snob.new(village: village.vid)
      @units[village.vid] = @train[village.vid].total_units
      @units[village.vid].snob = @snob[village.vid].total_snob
    end

    @fulls_atk = 0
    @fulls_def = 0

    @units.each do |k, u|
      if (u.population > 18000 && u.axe > 4000 && u.light > 2000)
        @fulls_atk += 1
      end

      if (u.population > 18000 && u.spear > 6000 && u.sword > 6000)
        @fulls_def += 1
      end

    end
  end

  def place
    @villages = Village.my.sort { |a, b| a.significant_name <=> b.significant_name }

    @places = (Parallel.map(@villages, in_threads: 1) do |village|
      [village.vid, Screen::Place.new(village: village.vid)]
    end).to_h

    @fulls_atk = 0
    @fulls_def = 0

    @places.each do |k,p|
      u = p.units

      if (u.population > 18000 && u.axe > 4999 && u.light > 2000)
        @fulls_atk += 1
      end

      if (u.population > 18000 && u.spear > 6000 && u.sword > 6000)
        @fulls_def += 1
      end

    end

  end

end