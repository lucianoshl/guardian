class User
  include Mongoid::Document
  field :name, type: String
  field :world, type: String
  field :password, type: String

  has_many :cookies, class_name: Cookie.to_s

  has_one :player

  def self.save_user
    username = ENV["TW_USER"]
    password = ENV["TW_PASSWORD"]
    world = ENV["TW_WORLD"]

    if ([password,world,username].compact.size != 3)
      raise Exception.new("Invalid user config TW_USER=#{ENV["TW_USER"]} TW_PASSWORD=#{ENV["TW_PASSWORD"]} TW_WORLD=#{ENV["TW_WORLD"]}")
    end

    user = User.new(name: username, world: world, password: password )
    user.save
    user
  end


  def self.current
    username = ENV["TW_USER"] || "default"
    Rails.cache.fetch("user_#{username}") do
      User.where(name: username).first 
    end
  end

end
