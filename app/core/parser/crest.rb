class Parser::Crest < Parser::Basic

  def parse screen
  	super
  	binding.pry
    self.targets = @page.search('#challenge_table tr').map do |line|
    	flag = line.search('img').attr('src').to_s.scan(/crest\/(.+)_/).flatten.first
    	binding.pry
    	next if (flag.nil?)


    	binding.pry
    end
    binding.pry
  	
  end

end