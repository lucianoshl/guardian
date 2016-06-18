class Screen::Logged < Screen::Anonymous

  def client
     if @client.nil?
      @client = Mechanize.new

      @client.user_agent = 'Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25'

      @client.add_cookies(Cookie.latest)
     end
    @client
  end

  def request url
    page = _request(method,url)
    puts "#{method} #{url}"
    if (!Cookie.is_logged?(page))
      client.add_cookies(Cookie.do_login)
      page = _request(method,url)
    end

    if (!Cookie.is_logged?(page))
      raise Exception.new("Error on login")
    end

    return page
  end

end