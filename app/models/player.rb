class Player
  include Mongoid::Document

  field :pid, type: Integer
  field :name, type: String
  field :points, type: Integer

  has_many :villages
  belongs_to :ally
  belongs_to :user

end
