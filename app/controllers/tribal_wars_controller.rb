class TribalWarsController < ApplicationController

  before_filter do 
    params.delete('controller') if params[:controller] == "tribal_wars"
    params.delete('action') if params[:action] == "get" || params[:action] == "post"
  end

  def page
    require 'open-uri'
    base = "https://#{User.current.world}.tribalwars.com.br"
    uri = base + request.fullpath
    download = open(uri)
    page = Tempfile.new('page')
    IO.copy_stream(download, page.path)
    # binding.pry

    send_file page.path, type: download.meta["content-type"], disposition: 'inline'
  end

  def proxy
    target_url = request.fullpath == '/game.php' ? '/game.php?screen=overview_villages' : request.fullpath

    base = "https://#{User.current.world}.tribalwars.com.br"

    headers = request.headers.to_h.select {|k,v| k.include?('HTTP_')}
    headers = (headers.map do |k,v|
      [k.gsub('HTTP_','').titleize.gsub(' ','-'),v]
    end).to_h

    headers.delete('Host')
    headers.delete('Referer')
    headers.delete('Cookie')

    method = request.method.downcase
    uri = base + target_url
    if (request.request_parameters.size > 0)
      page = client.send(method,uri,request.request_parameters,headers)
    else
      page = client.send(method,uri,headers)
    end

    if (page.class == Mechanize::Image) 
      binding.pry
      send_data page, type: page.response["content-type"], disposition: 'inline'
    else
      render :text => convert_links(page) 
    end

  end

  def get_parameters
    _get_parameters = (params.keys - request.request_parameters.keys)
    _get_parameters = params.select{|k,v| _get_parameters.include?(k)}
    return _get_parameters
  end

  def convert_links (page)
    if (page.class == Mechanize::File || page.title.nil?)
      return page.content
    end
    doc = Nokogiri::HTML(page.content)
    raw = doc.to_html
    world = User.current.world

    raw = raw.gsub(/\"\/js\//) do |str|
      "\"https://#{world}.tribalwars.com.br/js/"
    end

    raw = raw.gsub(/\"graphic/) do |str|
      "\"https://#{world}.tribalwars.com.br/graphic"
    end

    raw = raw.gsub(/\"\/graphic/) do |str|
      "\"https://#{world}.tribalwars.com.br/graphic"
    end

    return raw
  end

  def client
    Client::Logged.new
  end

end
