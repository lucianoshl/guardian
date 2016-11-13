class Parser::Snob < Parser::Basic

  def parse(screen)
    super
    screen.total_snob = @page.search('#content_value').text.scan(/\d+\/\d+/).first.split('/').last.extract_number
    screen.possible_coins = @page.search('#coin_mint_fill_max').extract_number
    if (screen.possible_coins > 0)
    	screen.coin_form = @page.forms.first
    end
  end

end