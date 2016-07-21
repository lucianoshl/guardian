class Parser::AllyContracts < Parser::Basic

  def parse(screen)
    super
    screen.allies = []
    finded = 0
    @page.search('#partners td,th').each do |cell|
      finded += 1 if (cell.name == 'th')
      
      if (finded < 3 && cell.search('a').size > 0)
        screen.allies << cell.search('a').attr('href').value.scan(/id=(\d+)/).first.first.to_i
      end

    end

  end

end