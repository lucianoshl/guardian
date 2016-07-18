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
      info = Screen::Main.new.buildings_metadata
      info.values.map(&:save)
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
    binding.pry
  end

end