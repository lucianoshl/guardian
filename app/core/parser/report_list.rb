class Parser::ReportList < Parser::Basic

  def parse(screen)
  	super
    screen.report_ids = @page.search('#report_list .quickedit').map{|a| a.attr('data-id').to_i}
  end

end