class LimitPlayerInDayException < Exception

  attr_accessor :distance

  def initialize distance
    self.distance = distance
  end
end

class Utils::PlayerGenerator

  def initialize
    @client = Utils::SurfClient.new
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
    game_screen = do_login(user)

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
  end

  def remove_player_friend_request
    buddies = Screen::Buddies.new
    @created_players.map do |user|
      buddies.cancel_request(user.name)
    end
  end

  def do_login(user)
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
    return game_screen
  end

  def register_mail(user)
    user = User.new(name: user)
    user.password = user.name.parameterize + "-12345"
    user.world = User.current.world
    do_login(user)

    binding.pry
  end

end
