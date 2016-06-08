class Screen::Login < Screen::Anonymous

  attr_accessor :cookies

  base 'https://www.tribalwars.com.br'
  endpoint '/index.php'
  url action: 'login', "server_#{User.first.world}": nil
  parameters({
    sso:0
  })

end