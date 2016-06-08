class Parser::Login < Parser::Abstract

  def parse screen
    if (@page.uri.to_s.include?("sid_wrong"))
      raise Exception.new("Error on login")
    end
    
    screen.cookies = screen.client.cookies
  end
end