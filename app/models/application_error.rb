class ApplicationError
  include Mongoid::Document

  field :stack, type: String
  field :event, type: DateTime

  def self.register(exception)
  end
end
