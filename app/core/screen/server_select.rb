class Screen::ServerSelect < Screen::Anonymous

  attr_accessor :hash_password

  base 'https://www.tribalwars.com.br'
  endpoint '/index.php'
  url action: 'login', show_server_selection: 1
  parameters({
    cookie: true,
    clear: true,
  })

end