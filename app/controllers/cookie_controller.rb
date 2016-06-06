class CookieController < ApplicationController
  def latest
    screen = Screen::Overview.new
    render json: Cookie.latest
  end
end
