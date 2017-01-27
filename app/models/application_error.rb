class ApplicationError
  include Mongoid::Document

  field :stack, type: String
  field :event, type: DateTime

  def self.register(e)
  	error = ApplicationError.new
  	error.event = Time.zone.now
  	error.stack = "#{e.backtrace.first}: #{e.message} (#{e.class})", e.backtrace.drop(1).map{|s| "\t#{s}"}
  	error.save
  end
end
