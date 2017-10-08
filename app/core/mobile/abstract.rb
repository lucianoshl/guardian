class Mobile::Abstract

	class << self
		attr_accessor :_entry,:_end_point,:_base,:_url
	end

	def self.entry arg
		self._entry = arg
	end

	def self.end_point arg
		self._end_point = arg
	end

	def self.base arg
		self._base = arg
	end

	def self.url arg
		self._url = arg
	end

	base 'https://www.tribalwars.com.br'
	end_point 'm/m'

	def initialize(*args)	
		@entry = self.class.ancestors.select{|a| a.respond_to? :_entry}.map(&:_entry).compact.first
		@end_point = self.class.ancestors.select{|a| a.respond_to? :_end_point}.map(&:_end_point).compact.first
		@base = self.class.ancestors.select{|a| a.respond_to? :_base}.map(&:_base).compact.first
		@url = self.class.ancestors.select{|a| a.respond_to? :_url}.map(&:_url).compact.first

		before_request(args)

		if (@url.nil?)
			parse(JSON.parse(post(args).body))
		else
			parse(get(@url.merge(args.first)))
		end 
		
	end

	def get(args)
		binding.pry
		client.get(generate_url,args)
	end

	def post(args)
		client.post(generate_url,args)
	end

	def before_request args
		return args
	end

	def generate_url(args = {})
		"#{@base}#{(@end_point.nil? || @end_point.empty?) ? '' : ('/' + @end_point)}/#{entry}"
	end

	def entry
		@entry || self.class.name.demodulize.downcase
	end

	def client
		@client = Mobile::Client.new if @client.nil?
		@client
	end

	def client_time
		Time.zone.now.to_i * 1000
	end
end