class Utils::SurfClient

  def initialize
    @client = Mechanize.new
    @client.agent.http.retry_change_requests = true
    # @client.user_agent_alias = 'iPhone'
    @client.open_timeout = @client.read_timeout = 20
    @bad_proxy = []
  end

  def clear
    @client.cookies.clear
  end

  def get url
    populate_proxy
    page = nil
    loop do
      begin
        # Rails.logger.info(url)
        page = @client.get(url)
        @current_proxy.up
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
        # Rails.logger.info(url)
        page = @client.post(url,parameters)
        @current_proxy.up

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
      proxy = proxy_list.shift
      Rails.logger.info("Using proxy #{proxy}")
      @current_proxy = proxy
      @client.set_proxy(proxy.host,proxy.port)
    end
    return @current_proxy
  end

  def discart_proxy
    @current_proxy.down
    @bad_proxy << @current_proxy
    @current_proxy = nil
    populate_proxy
  end

  def proxy_list
    if (@_proxy_list.nil?)
      @_proxy_list = Property::SurfProxy.desc(:level).to_a
    end
    return @_proxy_list
  end

end