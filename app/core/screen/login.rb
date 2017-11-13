class Screen::Login < Screen::Anonymous

  attr_accessor :cookies

  base 'https://www.tribalwars.com.br'
  endpoint '/index.php'
  url action: 'login', "server_#{$g.world}": nil
  parameters({
    sso:0
  })

end