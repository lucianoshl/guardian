class Screen::Logged < Screen::Anonymous

  def client
     if @client.nil?

      @client = Mechanize.new do|a|
        log = Logger.new STDOUT
        log.level = Logger::DEBUG
      end
      add_cookies(Cookie.latest)

     end
    @client
  end

  def request url
    page = client.send(method,url)
    if (!is_logged?(page))
      cookies = do_login
      add_cookies(cookies)
      page = client.send(method,url)
    end

    if (is_logged?(page))
      raise Exception.new("Error on login")
    end

    return page
  end

  def is_logged? page
    !page.uri.to_s.include?("sid_wrong") && page.search('input[type="password"]').empty?
  end

  def do_login

   login_screen = Screen::Login.new({
      user: User.first.name,
      password: Screen::ServerSelect.new.hash_password,
    })

    store_cookies(login_screen.cookies)
    return login_screen.cookies

  end

  def store_cookies cookies
    cookie = Cookie.new
    cookie.user = User.first
    cookie.content = cookies
    cookie.created_at = Time.zone.now
    cookie.save
  end

  def add_cookies(cookies)
    if (!cookies.nil?)
      @client.cookie_jar.clear!
      cookies.each do |c|
        @client.cookie_jar.add!(c)
      end
    end
  end

end