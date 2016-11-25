class Parser::Snob < Parser::Basic

  def parse(screen)
    super
    content = @page.search('#content_value').text.scan(/\d+\/\d+/).first

    screen.enabled = !content.nil?

    screen.possible_snobs = 0

    if (screen.enabled)
      screen.total_snob = content.split('/').last.extract_number
      screen.possible_snobs = @page.search('h3')[1].parent.search('span').last.extract_number
      screen.possible_coins = @page.search('#coin_mint_fill_max').extract_number
      if (screen.possible_coins > 0)
        screen.coin_form = @page.forms.first
      end
    end
  end

end