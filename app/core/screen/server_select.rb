class Screen::ServerSelect < Screen::Anonymous

  attr_accessor :hash_password

  base 'https://www.tribalwars.com.br'
  endpoint '/index.php'
  url action: 'login', show_server_selection: 1
  parameters({
    user: User.current.name,
    password: User.current.password,
    cookie: true,
    clear: true,
  })

end