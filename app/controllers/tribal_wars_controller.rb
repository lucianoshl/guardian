class TribalWarsController < ApplicationController

  before_filter do 
    params.delete('controller')
    params.delete('action')
  end

  def get
    if (!params.empty?)
      elements = params.to_query
    else
      elements = 'screen=place'
    end
    default_url = "/game.php?#{elements}"
    base = "https://#{User.current.world}.tribalwars.com.br"
    render :text => convert_links(client.get(base + default_url))
  end

  def post
    if (!params.empty?)
      elements = params.to_query
    else
      elements = 'screen=place'
    end
    default_url = "/game.php?#{elements}"
    base = "https://#{User.current.world}.tribalwars.com.br"
    render :text => convert_links(client.post(base + default_url,request.request_parameters))
  end

  def convert_links (page)
    doc = Nokogiri::HTML(page.content)
    raw = doc.to_html
    world = User.current.world
    raw = raw.gsub(/\"\/js\//) do |str|
      "\"https://#{world}.tribalwars.com.br/js/"
    end

    # binding.pry
    
    return raw
  end

  def client
    Client::Logged.new
  end

end
