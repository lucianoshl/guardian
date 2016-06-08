class Parser::ServerSelect < Parser::Abstract

  def parse screen
    screen.hash_password = @page.body.scan(/password.*?value=\\\"(.*?)\\/).first.first
  end

end