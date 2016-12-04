class Model::Buildings
  include Mongoid::Document

  field :main, type: Integer, default: 0
  field :barracks, type: Integer, default: 0
  field :stable, type: Integer, default: 0
  field :garage, type: Integer, default: 0
  field :snob, type: Integer, default: 0
  field :smith, type: Integer, default: 0
  field :place, type: Integer, default: 0
  field :statue, type: Integer, default: 0
  field :market, type: Integer, default: 0
  field :wood, type: Integer, default: 0
  field :stone, type: Integer, default: 0
  field :iron, type: Integer, default: 0
  field :farm, type: Integer, default: 0
  field :storage, type: Integer, default: 0
  field :hide, type: Integer, default: 0
  field :wall, type: Integer, default: 0

  embedded_in :village, class_name: Model::Village.to_s, inverse_of: 'buildings'


  def -(other)
    result = self.clone
    my_fields.map do |name|
      result[name] -= other[name]
    end
    return result
  end

  def total
    result = 0
    my_fields.map do |name|
      result += self[name]
    end
    result
  end

  def remove_negative
    result = self.clone
    my_fields.map do |name|
      if (result[name] < 0)
        result[name] = 0
      end
    end
    result
  end
  
end