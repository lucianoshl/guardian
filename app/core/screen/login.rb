class Screen::Login < Screen::Anonymous

  attr_accessor :cookies

  base 'https://www.tribalwars.com.br'
  endpoint '/index.php'
  url action: 'login', "server_#{ENV['TW_WORLD']}": nil
  parameters({
    sso:0
  })

end