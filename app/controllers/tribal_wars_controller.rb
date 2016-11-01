class TribalWarsController < ApplicationController

  before_filter do 
    params.delete('controller') if params[:controller] == "tribal_wars"
    params.delete('action') if params[:action] == "get" || params[:action] == "post"
  end

  def get
    target_url = request.fullpath == '/game.php' ? '/game.php?screen=overview_villages' : request.fullpath

    base = "https://#{User.current.world}.tribalwars.com.br"

    render :text => convert_links(client.get(base + target_url)) 
  end

  def post
    target_url = request.fullpath == '/game.php' ? '/game.php?screen=overview_villages' : request.fullpath

    base = "https://#{User.current.world}.tribalwars.com.br"

    render :text => convert_links(client.post(base + target_url,request.request_parameters))
  end

  def get_parameters
    _get_parameters = (params.keys - request.request_parameters.keys)
    _get_parameters = params.select{|k,v| _get_parameters.include?(k)}
    return _get_parameters
  end

  def convert_links (page)
    if (page.title.nil?)
      return page.content
    end
    doc = Nokogiri::HTML(page.content)
    raw = doc.to_html
    world = User.current.world
    raw = raw.gsub(/\"\/js\//) do |str|
      "\"https://#{world}.tribalwars.com.br/js/"
    end

    return raw
  end

  def client
    Client::Logged.new
  end

end
