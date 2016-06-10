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
      wood = obj.search('#wood').extract_number
      stone = obj.search('#stone').extract_number
      iron = obj.search('#iron').extract_number
    else
      wood = obj.search('.wood').first.parent.extract_number
      stone = obj.search('.stone').first.parent.extract_number
      iron = obj.search('.iron').first.parent.extract_number
    end

    new wood: wood, stone: stone, iron: iron
  end
end
