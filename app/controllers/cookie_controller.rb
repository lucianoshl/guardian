class CookieController < ApplicationController
  def latest
    screen = Screen::Place.new
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Request-Method'] = '*'
    result = {
      cookies: Cookie.latest,
      redirected_page: "https://#{User.current.world}.tribalwars.com.br/game.php?screen=place"
    }
    render json: result
  end
end
