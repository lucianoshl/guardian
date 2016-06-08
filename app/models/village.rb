class Village
  include Mongoid::Document
  field :vid, type: Integer
  field :x, type: Integer
  field :y, type: Integer

  field :name, type: String
  field :points, type: Integer

  field :state, type: String
  field :is_barbarian, type: Boolean
  
  def distance other
    Math.sqrt ((self.x - other.x)**2 + (self.y - other.y)**2)
  end

  def last_unsed_report
    nil
  end

end
