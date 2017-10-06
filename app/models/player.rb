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


  def self.unsaved pid
  	screen = Screen::InfoPlayer.new(id: pid)
  	binding.pry
  end

end
