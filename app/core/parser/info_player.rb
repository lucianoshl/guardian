class Parser::InfoPlayer < Parser::Abstract

  def parse(screen)
    screen.avatar_url = @page.search('img[alt="Imagem pessoal"]').first.attr('src')
  end

end