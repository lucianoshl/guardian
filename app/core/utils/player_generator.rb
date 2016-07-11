class LimitPlayerInDayException < Exception
end

class Utils::PlayerGenerator

  def get_proxy_list
    Rails.cache.fetch("best_proxy_cache", expires_in: 1.week) do
      if (@proxy_lists.nil?)
        @proxy_lists = []

        proxies = [
          OpenStruct.new(host: '114.215.176.223', port: 1080),
          OpenStruct.new(host: '123.168.91.4', port: 8888),
          OpenStruct.new(host: '195.12.21.130', port: 8080),
          OpenStruct.new(host: '219.255.197.90', port: 3128),
          OpenStruct.new(host: '112.111.227.76', port: 81),
          OpenStruct.new(host: '111.126.73.214', port: 8118),
          OpenStruct.new(host: '112.82.217.44', port: 81),
          OpenStruct.new(host: '112.230.141.200', port: 81),
          OpenStruct.new(host: '36.7.172.18', port: 82),
          OpenStruct.new(host: '203.195.170.25', port: 1080),
          OpenStruct.new(host: '119.177.81.206', port: 8888),
          OpenStruct.new(host: '119.186.48.35', port: 8888),
          OpenStruct.new(host: '125.161.170.204', port: 8080),
          OpenStruct.new(host: '169.50.87.252', port: 80),
          OpenStruct.new(host: '211.143.146.213', port: 80),
          OpenStruct.new(host: '115.28.230.210', port: 8080),
          OpenStruct.new(host: '39.87.17.93', port: 81),
          OpenStruct.new(host: '182.43.158.118', port: 8888),
          OpenStruct.new(host: '61.135.217.22', port: 80),
          OpenStruct.new(host: '60.13.74.141', port: 80),
          OpenStruct.new(host: '114.88.9.92', port: 1080),
          OpenStruct.new(host: '182.254.218.141', port: 80),
          OpenStruct.new(host: '211.143.155.222', port: 843)
        ]

        r = Mechanize.new.get("http://www.gatherproxy.com")
        r.body.scan(/PROXY_IP":"(.+?)".+?PROXY_PORT":"(.+?)"/).map do |item|
          proxies << OpenStruct.new(host: item[0], port: item[1].to_i(16))
        end

        threads = proxies.map do |proxy|
          
          Thread.new do
            client = Mechanize.new
            client.open_timeout   = 10
            client.read_timeout   = 10
            client.set_proxy(proxy.host,proxy.port)
            begin
              client.get("http://google.com")
              @proxy_lists << proxy
              puts "Proxy ok"
            rescue Exception => e
              puts "Proxy error"
            end
          end
        end
        threads.map(&:join)
      end
      @proxy_lists
    end
  end

  def get_proxy
    if (@current_proxy.nil?)
      free = (get_proxy_list - @invalid_proxies)
      binding.pry if (free.empty?)
      @current_proxy = free.shuffle.first
    end
    @current_proxy
  end

  def generate_user
    Rails.logger.info("Generate user: start")
    user = User.new
    user.name = I18n.transliterate(Mechanize.new.get("http://www.behindthename.com/random/random.php?number=2&gender=f&surname=&all=yes").search('.heavyhuge').text.strip).split(' ').join(' ')
    user.password = user.name.parameterize + "-12345"
    user.email = "#{user.name.parameterize}@invitect-company.com"
    user.world = User.current.world
    Rails.logger.info("Generate user: end")
    user
  end

  def register(user,invite_url)
    Rails.logger.info("Register: start")
    stop = false
    exclusive_client = @register_client
    exclusive_client.cookies.clear
    while (!stop)
        begin
          page = exclusive_client.get(invite_url)
        rescue Exception => e
          puts "get error #{e}"
          @invalid_proxies << @current_proxy.clone if (!@current_proxy.nil?)
          @current_proxy = nil
          proxy = get_proxy
          exclusive_client.set_proxy(proxy.host,proxy.port)
          next
        end
        form = page.form
        form['name'] = user.name
        form['password'] = user.password
        form['password_confirm'] = user.password
        form['email'] = user.email
        form['agb'] = 'on'
        result = form.submit
        if (result.search('.error').size > 0)
          puts "Error in register #{result.search('.error').text}"
          if (result.search('.error').text.include?("código"))
            exclusive_client.cookies.clear
            @invalid_proxies << @current_proxy.clone if (!@current_proxy.nil?)
            @current_proxy = nil
            proxy = get_proxy
            puts "Configure proxy #{proxy} and try again"
            exclusive_client.set_proxy(proxy.host,proxy.port)
            next
          else
            throw Exception.new(result.search('.error').text)
          end
        end

        stop = true
    end
    Rails.logger.info("Register: end")
  end

  def do_first_login(user)
    client = Mechanize.new
    params = {
      user: user.name,
      password: user.password,
      cookie: true,
      clear: true,
    }
    result = client.post("https://www.tribalwars.com.br/index.php?action=login&show_server_selection=1",params)

    hash_password = result.body.scan(/password.*?value=\\\"(.*?)\\/).first.first
    params = {
      user: user.name,
      password: hash_password,
    }

    response = client.post("https://www.tribalwars.com.br/index.php?action=login&server_#{User.current.world}",params)


    loop do
      result = response.form.submit
      if (result.body.include?("Ocorreu um erro desconhecido no servido"))
        next
      else
        break
      end
    end
    x,y = result.search('#menu_row2').text.scan(/(\d+)\|(\d+)/).flatten.map(&:to_i)
    created_village = Village.new(x:x, y:y)

    distance = Village.my.first.distance(created_village)
    puts "Generated distance = #{distance}"
    @created_players << user
    if (distance >= 100)
      raise LimitPlayerInDayException.new
    end
  end

  def run
    invite_url = Config.generate_player_arround.invite_url(nil)

    if (invite_url.nil?)
      return
    end

    @created_players = []
    @register_client = Mechanize.my
    @proxy_lists = nil
    @invalid_proxies = []
    @current_proxy = nil
    begin
      (1..5).each_with_index.map do |index|
        Rails.logger.info("Running number #{index}")
        user = generate_user
        register(user, invite_url)
        do_first_login(user)
      end
    rescue LimitPlayerInDayException => e

    end

    remove_player_friend_request    
  end

  def remove_player_friend_request
    buddies = Screen::Buddies.new
    @created_players.map do |user|
      buddies.cancel_request(user.name)
    end
  end

end
