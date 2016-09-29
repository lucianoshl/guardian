class Resource
  include Mongoid::Document

  field :wood, type: Integer, default: 0
  field :stone, type: Integer, default: 0
  field :iron, type: Integer, default: 0
  
  embedded_in :resourcesable, polymorphic: true

  after_initialize do
    self.wood ||= 0
    self.stone ||= 0
    self.iron ||= 0
  end

  def total
    wood + stone + iron
  end

  def self.parse(obj)
    if obj.search('#wood').length > 0
      element = obj.search('#wood').first
      wood = element.nil? ? 0 : element.extract_number
      element = obj.search('#stone').first
      stone = element.nil? ? 0 : element.extract_number
      element = obj.search('#iron').first
      iron = element.nil? ? 0 : element.extract_number 
    else
      element = obj.search('.wood')
      wood = element.first.nil? ? 0 : element.first.parent.extract_number
      element = obj.search('.stone')
      stone = element.first.nil? ? 0 : element.first.parent.extract_number
      element = obj.search('.iron')
      iron = element.first.nil? ? 0 : element.first.parent.extract_number
    end

    new wood: wood, stone: stone, iron: iron
  end

  def include?(other)
    !(self - other).has_negative?
  end

  def *(other)
    result = self.clone
    result.wood *= other
    result.stone *= other
    result.iron *= other
    return result
  end

  def +(other)
    result = self.clone
    result.wood += other.wood
    result.stone += other.stone
    result.iron += other.iron
    return result
  end

  def -(other)
    result = self.clone
    result.wood += other.wood
    result.stone += other.stone
    result.iron += other.iron
    return result
  end

  def has_negative?
    wood < 0 || stone < 0 || iron < 0
  end

end


class Hash
  def to_resource
    hash = self.with_indifferent_access
    result = Resource.new
    result.wood = hash["wood"]
    result.stone = hash["stone"]
    result.iron = hash["iron"]
    return result
  end
end