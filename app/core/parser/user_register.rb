class Parser::UserRegister < Parser::Abstract

  def parse(screen)
    screen.form =  @page.form
  end

end