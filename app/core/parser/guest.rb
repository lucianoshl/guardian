class Parser::Guest < Parser::Basic

  def parse(screen)
  	screen.result_list = table_with_title('#player_ranking_table').map do |row|
  		pid = row.search('td:eq(2) > a').first.attr('href').scan(/id=(\d+)/).first.first.to_i
  		{ pid: pid } 
  	end
  end

  def table_with_title(seletor)
  	seletor += " > tr"
  	result = @page.search(seletor).to_a
  	result.shift
  	return result
  end

end