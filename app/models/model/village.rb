class Model::Village
  include Mongoid::Document

  field :name, type: String
  embeds_one :troops, class_name: Model::Troop.to_s
  embeds_one :buildings, class_name: Model::Buildings.to_s
  embeds_many :priorities, class_name: Model::Buildings.to_s

  accepts_nested_attributes_for :troops
  accepts_nested_attributes_for :buildings 
  accepts_nested_attributes_for :priorities 

  has_many :villages, class_name: Village.to_s , inverse_of: :model

  def complete_building_model
    max_values = Model::Buildings.new

    config = self.priorities
    config << self.buildings
    config.each do |config|
      config.my_fields.each do |field|
        if (config[field] > max_values[field])
          max_values[field] = config[field]
        end
      end
    end
    max_values
  end

end
