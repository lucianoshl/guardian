class Model::Village
  include Mongoid::Document

  field :name, type: String
  embeds_one :troops, class_name: Troop.to_s
  embeds_one :buildings, class_name: Model::Buildings.to_s

  accepts_nested_attributes_for :troops
  accepts_nested_attributes_for :buildings 

  embedded_in :village

end
