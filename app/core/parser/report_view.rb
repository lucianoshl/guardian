class Parser::ReportView < Parser::Abstract

  def parse(screen)
    report = Report.new
    # binding.pry
    report.erase_url = @page.search('a[href*=del_one]').first.attr('href')
    # report.status
    # report.origin

    # target_id = page.search('#attack_info_def a[href*=info_village]').to_s.scan(/id=(\d+)/).extract_number

    # report.target = Village.where()
    # report.occurrence
    # report.luck
    # report.moral

    # report.origin_troops
    # report.origin_troops_losses

    # report.target_troops
    # report.target_troops_losses

    # report.pillage 
    binding.pry
  end

end