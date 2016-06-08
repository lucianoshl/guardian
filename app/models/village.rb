class Village
  include Mongoid::Document
  field :vid, type: Integer
  field :x, type: Integer
  field :y, type: Integer

  field :name, type: String
  field :points, type: Integer
  
  def distance other
    Math.sqrt ((self.x - other.x)**2 + (self.y - other.y)**2)
  end

end
