class Screen::Login < Screen::Anonymous

  attr_accessor :cookies

  base 'https://www.tribalwars.com.br'
  endpoint '/index.php'
  url action: 'login', "server_#{User.current.world}": nil
  parameters({
    sso:0
  })

end