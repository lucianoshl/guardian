class Ally
  include Mongoid::Document

  field :aid, type: Integer
  field :name, type: String
  field :points, type: Integer

  has_many :players
  has_many :partners, class_name: Ally.to_s
  belongs_to :partners_r, class_name: Ally.to_s, optional: true

end
