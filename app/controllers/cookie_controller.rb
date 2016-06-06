class CookieController < ApplicationController
  def latest
    screen = Screen::Overview.new
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Request-Method'] = '*'
    render json: Cookie.latest
  end
end
