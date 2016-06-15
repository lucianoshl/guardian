class User
  include Mongoid::Document
  field :name, type: String
  field :world, type: String
  field :password, type: String

  has_many :cookies, class_name: Cookie.to_s

  has_one :player


  def self.current
    key = ENV["user"] || "default"
    Rails.cache.fetch("user_#{key}") do
      if (ENV["user"].nil?)
        User.first
      else
        binding.pry
      end
    end
  end

end
