class Parser::Overview < Parser::Basic

  def parse screen
  	super
    screen.villages = [Village.new(x: 545, y:327)]
  end

end