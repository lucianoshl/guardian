class Parser::InfoPlayer < Parser::Abstract

  def parse(screen)
    element = @page.search('img[alt="Imagem pessoal"]').first
    if (!element.nil?)
      screen.avatar_url = element.attr('src')
    end

    if (!@page.search('a[href*=info_ally]').empty?)
    	screen.ally_id = @page.search('a[href*=info_ally]').attr('href').value.extract_number
    end

    screen.villages = @page.search('#villages_list .village_anchor').map{|a| a.attr('data-id').to_i }
  end

end
