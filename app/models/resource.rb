class Resource
  include Mongoid::Document

  field :wood, type: Integer, default: 0
  field :stone, type: Integer, default: 0
  field :iron, type: Integer, default: 0
  
  embedded_in :resourcesable, polymorphic: true

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

end
