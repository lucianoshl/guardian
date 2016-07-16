class Property::SurfProxy < Property::Simple
  field :host, type: String
  field :port, type: Integer
  field :level, type: Integer, default: 0

  def self.populate
    Rails.logger.info("Populate proxy: start")
    Rails.logger.info("Populate proxy: fetch saved proxies")
    models = fetch_remote.uniq.map do |new_proxy|
      Property::SurfProxy.where(new_proxy).first || Property::SurfProxy.new(new_proxy)
    end
    models.pmap(&:save)

    Rails.logger.info("Populate proxy: testing proxies")
    progress = 0
    mutex = Mutex.new
    models = models.map do |proxy|
      Thread.new do 
        begin
          Timeout::timeout(10) do
            c = Mechanize.new
            c.set_proxy(proxy.host,proxy.port)
            begin
              c.get("https://www.tribalwars.com.br/")
              proxy.level = proxy.level + 1
            rescue
              proxy.level = proxy.level - 1
            end
          end
        rescue
          proxy.level = proxy.level - 1
        end
        proxy.save
        mutex.synchronize { 
          progress += 1
          puts "#{models.size}/#{progress}"
           }
      end
    end
    models.map(&:join)
    Rails.logger.info("Populate proxy: end")
  end

  def self.fetch_remote
    r = Mechanize.new.get("http://www.gatherproxy.com")
    r.body.scan(/PROXY_IP":"(.+?)".+?PROXY_PORT":"(.+?)"/).map do |item|
      { host: item[0], port: item[1].to_i(16) }
    end
  end

end