
class MobileCookie
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
    last = MobileCookie.where(user: User.current).desc(:created_at).to_a.first
    last.nil? ? nil : last.content
  end

  def self.store_cookies cookies
    cookie = MobileCookie.new
    cookie.user = User.current
    cookie.content = cookies
    cookie.created_at = Time.zone.now
    cookie.save
  end

  def self.do_login
    login = Mobile::Login.from_user
    worlds = Mobile::Worlds.new(login.token)
    world_login_screen = Mobile::WorldLogin.new(login.token,2,'android')
    client = Mobile::Client.new
    client.get("https://#{User.current.world}.tribalwars.com.br/login.php?mobile&sid=#{world_login_screen.sid}&2")

    MobileCookie.where(user: User.current).delete
    MobileCookie.store_cookies(client.cookies)
    return Mobile::Client.client.cookies
  end

  def self.is_logged? page
    binding.pry
    !page.uri.to_s.include?("sid_wrong") && page.search('input[type="password"]').empty?
  end
end