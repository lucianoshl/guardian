class Screen::Logged < Screen::Anonymous

  def self.client
    _client = Mechanize.my
    # _client.user_agent_alias = 'iPhone'
    _client.add_cookies(Cookie.latest)
  end

  def client
    @client = Mobile::Client.client if @client.nil?
    @client
  end

  def parse page
    parser = self.class.name.gsub("Screen::","Parser::").constantize
    check_bot(page)
    parser.new(page).parse(self)
  end

  def check_bot page
    raise Exception.new("bot_protection") if (!page.search('body').attr('data-bot-protect').nil?) 
  end

  # def request url
  #   page = _request(method,url)
  #   Rails.logger.info "#{method} #{url}"
  #   if (!Cookie.is_logged?(page))
  #     client.add_cookies(Cookie.do_login)
  #     page = _request(method,url)
  #   end

  #   if (!Cookie.is_logged?(page))
  #     raise Exception.new("Error on login")
  #   end

  #   return page
  # end

  def request url
    page = _request(method,url)
    Rails.logger.info "#{method} #{url}"
    if (!Cookie.is_logged?(page))
      client.add_cookies(MobileCookie.do_login)
      page = _request(method,url)
    end

    if (!Cookie.is_logged?(page))
      raise Exception.new("Error on login")
    end

    return page
  end

end