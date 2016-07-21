class Parser::InfoPlayer < Parser::Abstract

  def parse(screen)
    element = @page.search('img[alt="Imagem pessoal"]').first
    if (!element.nil?)
      screen.avatar_url = element.attr('src')
    end
  end

end