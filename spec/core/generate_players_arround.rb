require 'rails_helper'

class PlayerGenerator

  def get_proxy_list
    [
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
  end

  def get_proxy
    if (@current_proxy.nil?)
      free = (get_proxy_list - @invalid_proxies)
      binding.pry if (free.empty?)
      return free.shuffle.first
    end
    Rails.logger.info "Using proxy=#{proxy.host}:#{proxy.port}"
    @current_proxy
  end

  def generate_user
    user = User.new
    user.name = I18n.transliterate(Mechanize.new.get("http://www.behindthename.com/random/random.php?number=2&gender=f&surname=&all=yes").search('.heavyhuge').text.strip).split(' ').join(' ')
    user.password = user.name.parameterize + "-12345"
    user.email = "#{user.name.parameterize}@invitect-company.com"
    user.world = User.current.world
    user
  end

  def register(user,invite_url)
    Rails.logger.info("Register: start")
    stop = false
    while (!stop)
      # begin
        proxy_conf = get_proxy

        profile = Selenium::WebDriver::Firefox::Profile.new
        proxy = Selenium::WebDriver::Proxy.new(:http => "#{proxy_conf.host}:#{proxy_conf.port}")
        profile.proxy = proxy
        driver = Selenium::WebDriver.for :firefox, :profile => profile
        browser = Watir::Browser.new(driver)
        browser.goto(invite_url)

        browser.text_field(:name => 'name').set user.name
        browser.text_field(:name => 'password').set user.password
        browser.text_field(:name => 'password_confirm').set user.password
        browser.text_field(:name => 'email').set user.email
        browser.text_field(:name => 'email').set user.email
        browser.checkbox(:name => 'agb').set 'on'
        browser.button(:name => 'submit').click

        binding.pry
        # exclusive_client = Mechanize.my
        # exclusive_client.set_proxy(proxy.host,proxy.port)
        
        # page = exclusive_client.get(invite_url)
        # form = page.form
        # form['name'] = user.name
        # form['password'] = user.password
        # form['password_confirm'] = user.password
        # form['email'] = user.email
        # form['agb'] = 'on'
        # result = form.submit
        if (result.search('.error').size > 0)
          throw Exception.new(result.search('.error').text)
        end

        stop = true
      # rescue Exception => e
      #   @invalid_proxies << @current_proxy
      #   @current_proxy = nil
      #   Rails.logger.error("Error in request #{e}")
      # end
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

    response.form.submit

  end

  def run
    @proxy_lists = []
    @invalid_proxies = []
    @current_proxy = nil
    (1..10).each_with_index.map do |index|
      Rails.logger.info("Running number #{index}")
      user = generate_user
      # register(user, Screen::InvitePlayer.new.invite_url)
      register(user, "https://www.tribalwars.com.br/register.php?ref_code=BR677Y57&ref=player_invite_linkrl")
      binding.pry
      do_first_login(user)
    end
    
  end

end


RSpec.describe do

  it "generate_players" do
    PlayerGenerator.new.run
  end

end

