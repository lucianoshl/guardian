class Screen::Logged < Screen::Anonymous

  def client
     if @client.nil?
      @client = Mechanize.new
      @client.add_cookies(Cookie.latest)
     end
    @client
  end

  def request url
    page = client.send(method,url)
    if (!is_logged?(page))
      client.add_cookies(Cookies.do_login)
      page = client.send(method,url)
    end

    if (!Cookie.is_logged?(page))
      raise Exception.new("Error on login")
    end

    return page
  end

end