class Model::Buildings
  include Mongoid::Document

  ::Metadata::Building.all.map(&:name).map do |building_name|
    field building_name.to_sym, type: Integer, default: 0
  end

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