class User
  include Mongoid::Document
  field :name, type: String
  field :world, type: String
  field :password, type: String
  field :email, type: String
  field :avatar_url, type: String, default: 'crow_45x45.png'
  field :pid, type: Integer
  field :main, type: Boolean

  has_many :cookies, class_name: Cookie.to_s

  has_one :player 

  def self.fake
    user = User.new
    user.name = I18n.transliterate(Mechanize.new.get("http://www.behindthename.com/random/random.php?number=2&gender=f&surname=&all=yes").search('.heavyhuge').text.strip).split(' ').join(' ')
    user.password = user.name + '1'
    user.email = "#{user.name.parameterize}@invitect-company.com"
    user.world = User.current.world
    user
  end

  def self.current
    Rails.cache.fetch("user_cached") do
      User.first
    end
  end

end
