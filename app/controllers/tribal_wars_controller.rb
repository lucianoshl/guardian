class TribalWarsController < ApplicationController

  before_action do 
    params.delete('controller') if params[:controller] == "tribal_wars"
    params.delete('action') if params[:action] == "get" || params[:action] == "post"
  end

  def page
    require 'open-uri'
    base = "https://#{User.current.world}.tribalwars.com.br"
    uri = base + request.fullpath

    path,content_type = Rails.cache.fetch("#{uri}_tmp_file") do
      download = open(uri)
      page = Tempfile.new('page')
      IO.copy_stream(download, page.path)
      [page.path,download.meta["content-type"]]
    end

    if (!File.exists?(path))
      Rails.cache.delete("#{uri}_tmp_file")
      path,content_type = Rails.cache.fetch("#{uri}_tmp_file") do
        download = open(uri)
        page = Tempfile.new('page')
        IO.copy_stream(download, page.path)
        [page.path,download.meta["content-type"]]
      end
    end


    send_file path, type: content_type, disposition: 'inline'
  end

  def proxy
    Rails.logger.info("proxy start".white.on_red)
    if (request.fullpath == '/game.php')

      screen = Village.my_cache.size > 1 ? "overview_villages" : "overview"

      redirect_to "/game.php?village=#{Village.my_cache.first.vid}&screen=#{screen}"
      return
    end
    target_url = request.fullpath

    base = "https://#{User.current.world}.tribalwars.com.br"

    headers = request.headers.to_h.select {|k,v| k.include?('HTTP_')}
    headers = (headers.map do |k,v|
      [k.gsub('HTTP_','').titleize.gsub(' ','-'),v]
    end).to_h

    # headers.delete('Host')
    headers['Host'] = "#{User.current.world}.tribalwars.com.br"
    # headers.delete('Referer')
    headers.delete('Cookie')

    method = request.method.downcase
    uri = base + target_url
    if (request.request_parameters.size > 0)
      page = client.send(method,uri,request.request_parameters,headers)
    else
      page = client.send(method,uri,headers)
    end

    Rails.logger.info(page.search('h2').text.white.on_red) if page.class != Mechanize::File
    
    Rails.logger.info("proxy end".white.on_red)

    if page.uri.to_s.include?('map.php')
      json = JSON.parse(page.body)

      json = convert_map_json(json)

      render :text => json.to_json
      return
    end

    if (page.class == Mechanize::Image) 
      send_data page, type: page.response["content-type"], disposition: 'inline'
    else
      render :text => convert_links(page) 
    end

  end

  def convert_map_json(json)
    village_map = Village.my_cache.map {|a| [a.vid,a]}.to_h
    json.each_with_index do |item,index|
      item["data"]["villages"].each_with_index do |item2,index2|

        if (item2.class == Array)
          aux = {}
          item2.each do |item|
            if (item.class == Hash)
              aux = aux.merge(item)
            end
            item2 = aux
          end
        end
        
        item2.map do |k,item3|
          if (village_map.keys.include?(item3.first.to_i))
            json[index]["data"]["villages"][index2][k][2] = village_map[item3.first.to_i].significant_name
          end
        end
      end
    end
    return json
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

    # decorator_name = 'Decorator::'+page.uri.to_s.scan(/screen=(\w+)/).first.first.camelize
    # begin
    #   Rails.logger.info("Decorator name : #{decorator_name}")
    #   decorator = decorator_name.constantize.new
    # rescue
    # end

    Village.my_cache.pmap do |village|
      title = doc.search('title').first
      if (!title.content.scan("#{village.name} (#{village.x}|#{village.y})").empty?)
        title.content = title.content.gsub(village.name,village.significant_name)
      end

      doc.search("a[href*='#{village.vid}']").map do |element|
        wrapper = element.search("*:contains('#{village.name}')").first

        if (!wrapper.nil?)
          wrapper.content = wrapper.content.gsub(village.name,village.significant_name)
        elsif (element.text.include?(village.name))
          element.content = element.content.gsub(village.name,village.significant_name)
        end
      end
    end

    decorator.html(doc) if (decorator.respond_to?("html"))

    Decorator::Global.new.html(doc,request)

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

    raw = decorator.raw(raw) || raw if (decorator.respond_to?("raw"))

    return raw
  end

  def image
    binding.pry
  end

  def client
    Client::Logged.new
  end

end
