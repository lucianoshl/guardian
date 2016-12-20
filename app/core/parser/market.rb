class Parser::Market < Parser::Basic

  def parse(screen)
    super
    info = ExecJS.eval(@page.body.scan(/var Data = ({(?:.|\n)*?});/).first.first)
    
    screen.trader = OpenStruct.new info['Trader']
    screen.trader.incomming = Resource.new

    if (!@page.search('th:contains("Entrada")').first.nil?)
	    @page.search('th:contains("Entrada")').first.parent.search('.icon').map do |item|
	    	item = item.parent
	    	screen.trader.incomming[item.search('span').first.attr('class').split(' ').last] = item.text.extract_number
	    end
    end


    screen.trader.resources_disponible = Resource.new ExecJS.eval(@page.body.scan(/var res = ({(?:.|\n)*?});/).first.first)

    screen.send_resource_form = @page.forms.first
  end

end