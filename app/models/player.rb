class Player
  include Mongoid::Document

  field :pid, type: Integer
  field :name, type: String
  field :points, type: Integer

  field :in_blacklist, type: Boolean

  has_many :villages
  belongs_to :ally
  belongs_to :user


  scope :blacklist, -> { where(in_blacklist: true)}

end
