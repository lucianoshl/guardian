class Parser::ReportList < Parser::Abstract

  def parse(screen)
    screen.report_ids = @page.search('#report_list .quickedit').map{|a| a.attr('data-id').to_i}
  end

end