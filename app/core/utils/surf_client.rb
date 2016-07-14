class Utils::SurfClient

  def initialize
    @client = Mechanize.new
    @client.agent.http.retry_change_requests = true
    @client.user_agent_alias = 'iPhone'
    @client.open_timeout = @client.read_timeout = 20
    @bad_proxy = []
  end

  def get url
    populate_proxy
    page = nil
    loop do
      begin
        page = @client.get(url)
        break
      rescue Exception => e
        Rails.logger.info("Proxy error: #{e}")
        discart_proxy
        next
      end
    end
    return page
  end


  def post url,parameters,&block
    populate_proxy
    page = nil
    loop do
      begin
        page = @client.post(url,parameters)

        if (!block.nil? && block.call(page))
          # binding.pry
          next
        end

        break
      rescue Exception => e
        Rails.logger.info("Proxy error: #{e}")
        discart_proxy
        next
      end
    end
    return page
  end

  def submit form,&block
    result = nil
    loop do
      begin
        result = form.submit
        if (block.call(result))
          break
        else
          discart_proxy
          next
        end
      rescue
        discart_proxy
        next
      end
    end
    return result
  end


  def populate_proxy
    if (@current_proxy.nil?)
      proxy = next_proxy
      Rails.logger.info("Using proxy #{proxy}")
      @current_proxy = @client.set_proxy(proxy.host,proxy.port)
    end
    return @current_proxy
  end

  def discart_proxy
    @bad_proxy << @current_proxy
    @current_proxy = nil
    populate_proxy
  end

  def next_proxy
    proxy_list.shift
    # proxy_list.select do |proxy|
    #   @bad_proxy.include?(proxy)
    # end)

    # (proxy_list - @bad_proxy).first
  end

  def proxy_list
    if (@_proxy_list.nil?)
      @_proxy_list = []
      untested_proxy = []
      r = Mechanize.new.get("http://www.gatherproxy.com")
      r.body.scan(/PROXY_IP":"(.+?)".+?PROXY_PORT":"(.+?)"/).map do |item|
        untested_proxy << OpenStruct.new(host: item[0], port: item[1].to_i(16))
      end

      Rails.logger.info("Testing proxy list: start")
      progress = 0

      bad_proxy = Property::BadProxy.all.map(&:content)

      untested_proxy = untested_proxy.select{|p| !bad_proxy.include?(p.host)}

      threads = untested_proxy.map do |proxy|
        Thread.new do
          c = Mechanize.new
          c.set_proxy(proxy.host,proxy.port)
          begin
            c.get("https://www.tribalwars.com.br/")
            @_proxy_list << proxy
          rescue
            Property::BadProxy.new(content: proxy.host).save
          end
          progress += 1
          puts "#{untested_proxy.size}/#{progress}"
        end
      end
      threads.map(&:join)
      Rails.logger.info("Testing proxy list: end with #{@_proxy_list.size} proxies")

    end
    return @_proxy_list
  end

end