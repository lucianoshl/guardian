class Metadata::Building
  include Mongoid::Document
  field :name, type: String
  field :label, type: String

  field :max_level, type: Integer
  field :min_level, type: Integer

  field :wood_factor, type: Float
  field :stone_factor, type: Float
  field :iron_factor, type: Float
  field :pop_factor, type: Float
  field :build_time_factor, type: Float

  field :wood, type: Integer
  field :stone, type: Integer
  field :iron, type: Integer
  field :pop, type: Integer

  def self.populate
    if (count.zero?)
      page = Mechanize.new.get("http://br.twstats.com/#{User.current.world}/index.php?page=buildings")
      buildings = page.search('.r1,.r2').map do |row|
        building = self.new

        column = row.search('td').map(&:text) 

        building.name = row.search('a').attr('href').value.scan(/detail=(.+)/).first.first
        building.label = column[0]

        building.max_level = column[1].to_i
        building.min_level = column[2].to_i

        building.wood = column[3].to_i
        building.stone = column[4].to_i
        building.iron = column[5].to_i
        building.pop = column[6].to_i

        building.wood_factor = column[7].to_f
        building.stone_factor = column[8].to_f
        building.iron_factor = column[9].to_f
        building.pop_factor = column[10].to_f
        building.build_time_factor = column[12].to_f
        building
      end
      buildings.map(&:save)
      # info = Screen::Main.new.buildings_metadata
      # info.values.map(&:save)
    end
  end

  def cost(level)
    resource = Resource.new
    resource.wood = (wood * wood_factor ** (level - 1)).round
    resource.stone = (stone * stone_factor ** (level - 1)).round
    resource.iron = (iron * iron_factor ** (level - 1)).round
    resource
  end

  def population_cost(level)
    population(level) - population(level-1)
  end

  def population(level)
    (attributes["pop"] * pop_factor ** (level - 1)).round
  end

end