class Parser::Overview < Parser::Abstract

  def parse screen
    screen.villages = [OpenStruct.new(x: 545, y:327)]
  end

end