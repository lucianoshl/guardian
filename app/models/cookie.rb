class Cookie
  include Mongoid::Document

  field :content_yaml, type: String
  field :created_at, type: Date
  belongs_to :user

  def content= object
    self.content_yaml = YAML.dump(object)
  end

  def content
    YAML.load(content_yaml)
  end

  def self.latest
    last = Cookie.where(user: User.current).desc(:created_at).to_a.first
    last.nil? ? nil : last.content
  end


  def self.store_cookies cookies
    cookie = Cookie.new
    cookie.user = User.current
    cookie.content = cookies
    cookie.created_at = Time.zone.now
    cookie.save
  end

  def self.do_login

   login_screen = Screen::Login.new({
    user: User.current.name,
    password: Screen::ServerSelect.new(user: User.current.name, password: User.current.password).hash_password,
    })

   Cookie.where(user: User.current).delete
   Cookie.store_cookies(login_screen.cookies)
   return login_screen.cookies
  end

  def self.is_logged? page
    !page.uri.to_s.include?("sid_wrong") && page.search('input[type="password"]').empty?
  end
end