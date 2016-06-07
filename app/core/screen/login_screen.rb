class Screen::LoginScreen < Screen::Anonymous

  attr_accessor :cookies

  base 'https://www.tribalwars.com.br'
  endpoint '/index.php'
  url action: 'login', "server_#{User.first.world}": nil
  parameters({
    sso:0
  })

  def parse page
    if (page.uri.to_s.include?("sid_wrong"))
      raise Exception.new("Error on login")
    end

    self.cookies = @client.cookies
  end
end