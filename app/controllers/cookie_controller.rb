class CookieController < ApplicationController
  def latest
    screen = Screen::Overview.new
    @response.headers["Access-Control-Allow-Origin"] = "*"
    render json: Cookie.latest
  end
end
