class CookieController < ApplicationController
  def latest
    screen = Screen::Overview.new
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Request-Method'] = '*'
    result = {
      cookies: Cookie.latest,
      redirected_page: "https://#{User.first.world}.tribalwars.com.br/game.php?screen=overview"
    }
    render json: 
  end
end
