class CookieController < ApplicationController
  def latest
    # screen = Screen::Overview.new
    Screen::Logged.do_login
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Request-Method'] = '*'
    result = {
      cookies: Cookie.latest,
      redirected_page: "https://#{User.first.world}.tribalwars.com.br/game.php?screen=place"
    }
    render json: result
  end
end
