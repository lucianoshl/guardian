class Screen::Anonymous

  class << self
    attr_accessor :_parameters,:_url,:_base,:_endpoint,:_cache
  end

  def self.url url
    self._url = url
  end

  def self.cache _cache
    self._cache = _cache
  end

  def self.base base
    self._base = base
  end

  def self.endpoint endpoint
    self._endpoint = endpoint
  end

  def self.parameters parameters
    self._parameters = parameters
  end

  def initialize args={}
    @parameters = self.class._parameters.nil? ? nil : self.class._parameters.clone
    @url  = self.class._url.nil? ? {} : self.class._url.clone
    if (@parameters.nil?)
      @url = @url.merge(args)
    else
      @parameters = @parameters.merge(args)
    end

    # Rails.cache.fetch(url,cache_config) do
      parse(client.send(method,url))
    # end
    
  end

  def cache_config
    cache_config = {}
    cache_config[:force] = true

    if (!self.class._cache.nil?)
      cache_config[:force] = self.class._cache.nil?
      cache_config[:expires_in] = self.class._cache
    end
  end

  def parse page
    parser = self.class.name.gsub("Screen::","Parser::").constantize
    parser.new(page).parse(self)
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
    @parameters.nil? ? :get : :post
  end

  def base_url
    self.class._base || "https://#{User.current.world}.tribalwars.com.br"
  end

  def gen_url
    "#{base_url}#{self.class._endpoint || '/game.php'}?#{@url.to_query}"
  end

  def request url
    client.cookie_jar.clear!
    puts "#{method} : #{url} #{@parameters}"
    client.send(method,url,@parameters)
  end

end
