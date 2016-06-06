class Screen::Logged

  def self.url map
    @@url = map
  end

  def client
     if @client.nil?
      @client = Mechanize.new
      cookies = Cookie.latest

      if (!cookies.nil?)
        @client.cookie_jar.clear
        cookies.each do |c|
          @client.cookie_jar.add!(c)
        end
      end
     end
    @client
  end

  def method
    @parameters.nil? ? :get : :post
  end

  def base_url
    "https://#{User.first.world}.tribalwars.com.br"
  end

  def gen_url
    "#{base_url}/game.php?#{@url.to_query}"
  end

  def request url
    page = client.send(method,url)

    if (!is_logged?(page))
      do_login
      page = client.send(method,url)
    end

    if (!is_logged?(page))
      raise Exception.new("Error on login")
    end

    return page
  end

  def is_logged? page
    !page.uri.to_s.include?("sid_wrong")
  end

  def do_login
    user = User.first
    parameters =    {
      user: user.name,
      password: user.password,
      cookie: true,
      clear: true,
    }
    page = client.post("https://www.tribalwars.com.br/index.php?action=login&show_server_selection=1",parameters)

    parameters = {
      user: user.name,
      password: page.body.scan(/password.*?value=\\\"(.*?)\\/).first.first,
      sso:0
    }

    page = client.post("https://www.tribalwars.com.br/index.php?action=login&server_br76",parameters)

    if (!is_logged?(page))
      raise Exception.new("Error on login")
    else
      store_cookies
    end

  end

  def store_cookies
    cookie = Cookie.new
    cookie.user = User.first
    cookie.content = client.cookies
    cookie.created_at = Time.zone.now
    cookie.save
  end

  def initialize args={}
    @url  = @@url.merge(args)
    parse(request(gen_url()))
  end

end