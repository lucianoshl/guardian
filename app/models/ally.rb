class Ally
  include Mongoid::Document

  field :aid, type: Integer
  field :name, type: String
  field :points, type: Integer

  has_many :players

end
