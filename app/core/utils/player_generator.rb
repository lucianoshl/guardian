class LimitPlayerInDayException < Exception

  attr_accessor :distance

  def initialize distance
    self.distance = distance
  end
end



class Utils::PlayerGenerator

  # def get_proxy_list
  #   Rails.cache.fetch("best_proxy_cache", expires_in: 1.week) do
  #     if (@proxy_lists.nil?)
  #       @proxy_lists = []

  #       proxies = []

  #       r = g_client.get("http://www.gatherproxy.com")
  #       r.body.scan(/PROXY_IP":"(.+?)".+?PROXY_PORT":"(.+?)"/).map do |item|
  #         proxies << OpenStruct.new(host: item[0], port: item[1].to_i(16))
  #       end

  #       threads = proxies.map do |proxy|

  #         Thread.new do
  #           client = g_client
  #           client.open_timeout   = 10
  #           client.read_timeout   = 10
  #           client.set_proxy(proxy.host,proxy.port)
  #           begin
  #             client.get("http://google.com")
  #             @proxy_lists << proxy
  #             puts "Proxy ok"
  #           rescue Exception => e
  #             puts "Proxy error"
  #           end
  #         end
  #       end
  #       threads.map(&:join)
  #     end
  #     @proxy_lists
  #   end
  # end

  def get_proxy
    if (@current_proxy.nil?)
      free = (get_proxy_list - @invalid_proxies)
      binding.pry if (free.empty?)
      @current_proxy = free.shuffle.first
    end
    @current_proxy
  end

  def register(user,invite_url) 
    register_page = @client.get(invite_url)
    form = register_page.form
    form.fill(user.attributes.merge(password_confirm: user.password, agb: 'on'))

    result = @client.submit(form) do |result|
      result.search('.error').size == 0
    end

    if (result.search('.error').size > 0)
      binding.pry
    end
  end

  def do_first_login(user)
    base = "https://www.tribalwars.com.br"
    select_world_page = @client.post("#{base}/index.php?action=login&show_server_selection=1",{
      user: user.name,
      password: user.password,
      cookie: true,
      clear: true
      });

    game_screen = @client.post("#{base}/index.php?action=login&server_#{User.current.world}",{
        user: user.name,
        password: select_world_page.body.scan(/password.*?value=\\\"(.*?)\\/).first.first,
        }) do |game_screen|
      game_screen.title.include?("Problemas")
    end

    # enter_world_screen

    # game_screen = enter_world_screen.form.submit
    
    x,y = game_screen.body.scan(/(\d+)\|(\d+)/).flatten.pop(2).map(&:to_i)
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

    @client = Utils::SurfClient.new

    invite_urls = Property::InviteUrl.all

    invite_urls.to_a.map do |invited_url|
      (1..5).each_with_index.map do |index|
        Rails.logger.info("Running for #{invited_url.user}")

        if (!invited_url.limit_exceeded.nil? && !(invited_url.limit_exceeded < Time.zone.now.beginning_of_day.to_date))
          Rails.logger.info("Invite #{invited_url.user} exceeded")
          next
        end
        
        user = User.fake
        register(user,invited_url.content)
        begin
          do_first_login(user)
        rescue LimitPlayerInDayException => e
          invited_url.limit_exceeded = Time.zone.now
          invited_url.save
          invited_url.reload
        end
      end
    end


    # @created_players = []
    # @register_client = g_client
    # @proxy_lists = nil
    # @invalid_proxies = []
    # @current_proxy = nil

    # invite_urls = Property::InviteUrl.all

    # invite_urls.to_a.map do |model|

    #   if (model.user.nil? || model.user == "") 
    #     model.user = g_client.get(model.content).body.scan(/pelo jogador (.+) para/).first.first
    #     model.save
    #   end

    #   # if (!model.limit_exceeded.nil? && !(model.limit_exceeded < Time.zone.now.beginning_of_day.to_date))
    #   #   Rails.logger.info("Invite #{model.user} exceeded")
    #   #   next
    #   # end

    #   invite_url = model.content
    #   begin
    #     (1..5).each_with_index.map do |index|
    #       Rails.logger.info("Running number #{index} for #{model.user}")
    #       user = FakePlayer.new
    #       register(user, invite_url)
    #       do_first_login(user)
    #     end
    #   rescue LimitPlayerInDayException => e
    #     model.limit_exceeded = Time.zone.now
    #     model.save
    #     model.reload
    #   end
    # end


  end

  def remove_player_friend_request
    buddies = Screen::Buddies.new
    @created_players.map do |user|
      buddies.cancel_request(user.name)
    end
  end

end
