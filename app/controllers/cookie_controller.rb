class CookieController < ApplicationController
  def latest
    url = "https://#{User.current.world}.tribalwars.com.br/game.php?screen=place"
    page = Mechanize.my.add_cookies(Cookie.latest).get(url)

    if (!Cookie.is_logged?(page))
      Cookie.do_login
    end

    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Request-Method'] = '*'
    result = {
      cookies: remove_mobile(Cookie.latest),
      redirected_page: "https://#{User.current.world}.tribalwars.com.br/game.php?screen=place"
    }
    render json: result
  end

  def remove_mobile list
    list.select{|a| a.name != "mobile" }
  end
end
