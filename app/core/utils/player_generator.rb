class LimitPlayerInDayException < Exception

  attr_accessor :distance

  def initialize distance
    self.distance = distance
  end
end

class Utils::PlayerGenerator

  def g_client
    c = Mechanize.my
    c.agent.http.retry_change_requests = true
    c
  end 


  def get_proxy_list
    Rails.cache.fetch("best_proxy_cache", expires_in: 1.week) do
      if (@proxy_lists.nil?)
        @proxy_lists = []

        proxies = []

        r = g_client.get("http://www.gatherproxy.com")
        r.body.scan(/PROXY_IP":"(.+?)".+?PROXY_PORT":"(.+?)"/).map do |item|
          proxies << OpenStruct.new(host: item[0], port: item[1].to_i(16))
        end

        threads = proxies.map do |proxy|

          Thread.new do
            client = g_client
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
    user.name = I18n.transliterate(g_client.get("http://www.behindthename.com/random/random.php?number=2&gender=f&surname=&all=yes").search('.heavyhuge').text.strip).split(' ').join(' ')
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
    proxy = get_proxy
    exclusive_client.set_proxy(proxy.host,proxy.port)
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
    client = g_client
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

    loop do
      first_screen = client.post("https://www.tribalwars.com.br/index.php?action=login&server_#{User.current.world}",params)

      if (first_screen.title.include?("Problemas"))
        next
      else
        loop do 
          result = first_screen.form.submit
          if (result.title.include?("Problemas"))
            next
          else
            break
          end
        end
        break
      end
    end
    x,y = result.body.scan(/(\d+)\|(\d+)/).flatten.pop(2).map(&:to_i)
    created_village = Village.new(x:x, y:y)

    distance = Village.my.first.distance(created_village)
    puts "Generated distance = #{distance}"
    if (distance >= 20)
      raise LimitPlayerInDayException.new(distance)
    end
    Property::InvitedUser.new(user: user.name, distance:distance).save
    return distance
  end

  def run
    @created_players = []
    @register_client = g_client
    @proxy_lists = nil
    @invalid_proxies = []
    @current_proxy = nil

    invite_urls = Property::InviteUrl.all

    invite_urls.to_a.map do |model|

      if (model.user.nil? || model.user == "") 
        model.user = g_client.get(model.content).body.scan(/pelo jogador (.+) para/).first.first
        model.save
      end

      if (!model.limit_exceeded.nil? && !(model.limit_exceeded < Time.zone.now.beginning_of_day.to_date))
        Rails.logger.info("Invite #{model.user} exceeded")
        next
      end

      invite_url = model.content
      begin
        (1..5).each_with_index.map do |index|
          Rails.logger.info("Running number #{index} for #{model.user}")
          user = generate_user
          register(user, invite_url)
          do_first_login(user)
        end
      rescue LimitPlayerInDayException => e
        model.limit_exceeded = Time.zone.now
        model.save
        model.reload
      end
    end


  end

  def remove_player_friend_request
    buddies = Screen::Buddies.new
    @created_players.map do |user|
      buddies.cancel_request(user.name)
    end
  end

end
