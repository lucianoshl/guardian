class Parser::ReportView < Parser::Basic

  def parse(screen)
    super

  end

  def parse_report_troops(line_report)
    label,*amount = line_report.search('td')
    amount = amount.map{|a| a.text.to_i}

    result = {}
    @units.each_with_index do |unit, index|
      result[unit] = amount[index]
    end
    
    return result
  end

end