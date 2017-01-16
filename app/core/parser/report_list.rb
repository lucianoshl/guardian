class Parser::ReportList < Parser::Basic

  def parse(screen)
  	super
    screen.report_ids = (@page.search('#report_list .quickedit').map do |a| 

      if (a.search('img[src*=forwarded]').empty?)
        a.attr('data-id').to_i
      end

    end).compact
    
    if (!@page.search('.evt-confirm').empty?)
    	screen.erase_all_url = @page.search('.evt-confirm').attr('href').text
    end
    

  end

end