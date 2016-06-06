class User
  include Mongoid::Document
  field :name, type: String
  field :world, type: String
  field :password, type: String

  has_many :cookies, class_name: Cookie.to_s

end
