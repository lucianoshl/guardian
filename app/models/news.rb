class News
  include Mongoid::Document

  field :content, type: String
  field :read, type: Boolean, default: false

end
