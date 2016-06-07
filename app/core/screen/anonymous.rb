class Screen::Anonymous

  @@endpoint = '/game.php'
  @@base = nil

  def self.url url
    @@url = url
  end

  def self.base base
    @@base = base
  end

  def self.endpoint endpoint
    @@endpoint = endpoint
  end

  def self.parameters parameters
    @@parameters = parameters
  end

  def client
    if (@client.nil?)
      @client = Mechanize.new do|a|
        log = Logger.new "/tmp/info.tmp"
        log.level = Logger::INFO
      end
    end
    return @client
  end

  def method
    defined?(@@parameters).nil? ? :get : :post
  end

  def base_url
    @@base || "https://#{User.first.world}.tribalwars.com.br"
  end

  def gen_url
    "#{base_url}#{@@endpoint}?#{@url.to_query}"
  end

  def request url
    client.cookie_jar.clear!
    client.send(method,url,@@parameters)
  end

  def initialize args={}
    @url  = @@url.merge(args)
    parse(request(gen_url()))
  end

end