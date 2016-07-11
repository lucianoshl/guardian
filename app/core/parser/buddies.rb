class Parser::Buddies < Parser::Basic

  def parse screen
    super
    screen.requests = @page.search('a[href*=reject_buddy]').map do |item|
      request = OpenStruct.new
      request.name = item.parents(2).text.strip!
      request.request_url = item.attr('href')
      request
    end
  end

end