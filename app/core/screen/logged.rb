class Screen::Logged < Screen::Anonymous

  def client
     if @client.nil?
      @client = Mechanize.my

      @client.user_agent_alias = 'iPhone'

      @client.add_cookies(Cookie.latest)
     end
    @client
  end

  def request url
    page = _request(method,url)
    Rails.logger.info "#{method} #{url}"
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