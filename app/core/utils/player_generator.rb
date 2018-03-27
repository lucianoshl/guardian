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
    if (distance >= 40)
      raise LimitPlayerInDayException.new(distance)
    end
    Property::InvitedUser.new(name: user.name, distance:distance).save
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

    user.name = user.user if user.respond_to?("user")

    if (user.password.nil?)
      user.password = user.name.parameterize + "-12345"
    end

    select_world_page = @client.post("#{base}/index.php?action=login&show_server_selection=1",{
      user: user.name,
      password: user.password,
      cookie: true,
      clear: true
      });

    if (select_world_page.body.include?("error"))
      user.password = user.name + "1"
      select_world_page = @client.post("#{base}/index.php?action=login&show_server_selection=1",{
        user: user.name,
        password: user.password,
        cookie: true,
        clear: true
        });
    end

    binding.pry if (select_world_page.body.include?("error")) 

    user.save

    game_screen = @client.post("#{base}/index.php?action=login&server_#{ENV['TW_WORLD']}",{
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
    user.world = ENV['TW_WORLD']
    do_login(user)

    binding.pry
  end

  def grow_accounts
    original_user = User.current
    # users = Property::InvitedUser.where(password: nil).asc(:distance).to_a
    users = Property::InvitedUser.where(name: 'Yuina Nedelka').to_a
    users.each_with_index.map do |user,i|

      attrs = {name: user.name, password: user.password, world: original_user.world}
      user = User.where(attrs).first || User.new(attrs)
      user.save

      User.stub(:current) { user }
      Rails.logger.info("Running for player #{user} #{users.size}/#{i}")
      @client.clear



      do_login(user)

      # form = @client.get("https://#{ENV['TW_WORLD']}.tribalwars.com.br/game.php?village=18066&screen=settings&mode=account").form

      # form['email'] = "robertohlnero+#{user.name.gsub(' ','-')}@gmail.com"
      # form['password'] = user.password
      # form.submit

      build = ["wood","stone","iron","wood","stone","main","main","barracks","barracks","wood","stone","storage","storage","iron","barracks","statue"]

      page = @client.get("https://#{ENV['TW_WORLD']}.tribalwars.com.br/game.php?village=18066&screen=main")

      while(!build.empty?)
        target = build.shift

        url = page.search('a[href*="id=main"]').first.attr('href').gsub('&cheap','')
        page = @client.get("https://#{ENV['TW_WORLD']}.tribalwars.com.br/#{url}")

        url = page.search('a[href*="BuildTimeReduction"]').first.attr('href')
        page = @client.get("https://#{ENV['TW_WORLD']}.tribalwars.com.br/#{url}")
        binding.pry
      end




      binding.pry




      # result = Screen::Place.new({},@client).village.name
      # binding.pry
    end
  end

end
