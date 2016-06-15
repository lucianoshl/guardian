class Parser::ReportView < Parser::Basic

  def parse(screen)
    super
    @units = @page.search("#attack_info_att tr:eq(3) img").map{|i| i.attr('src').scan(/unit_(.+)\./) }.flatten

    screen.report = report = Report.new

    report.moral = @page.search('#attack_luck').first.next.next.text.extract_number

    report.erase_url = @page.search('a[href*=del_one]').first.attr('href')

    color = @page.search('img[src*=dots]').first.attr('src').scan(/dots\/(.+)\.png/).first.first
    enum = {
      blue: "spy",
      green: "win",
      yellow: "win_lost",
      red: "lost",
      error: "unknown"
    }

    report.status = enum[color.to_sym] || "error"
    report.target = Village.find_by(vid: @page.search('#attack_info_def .village_anchor').attr('data-id').value)
    report.origin = Village.find_by(vid: @page.search('#attack_info_att .village_anchor').attr('data-id').value)

    report.occurrence = @page.search('img[src*="dots"]').first.parents(3).search('tr')[1].search('td:last').text.parse_datetime

    report.origin_troops = parse_report_troops(@page.search("#attack_info_att_units tr")[1])
    report.origin_troops_losses = parse_report_troops(@page.search("#attack_info_att_units tr")[2])

    if (report.status != :lost) 

      if (@page.search('table[id*=attack_spy_buildings]').size > 0) 
        report.target_buildings = {}
        @page.search('table[id*=attack_spy_buildings]').search('img').each do |img|
          house = img.attr('src').scan(/\/([a-z]*).png/).flatten.first
          report.target_buildings[house] = img.parents(2).search('td').last.extract_number
        end
      end

      report.target_troops = parse_report_troops(@page.search("#attack_info_def tr:eq(3) tr")[1]) 
      report.target_troops_losses = parse_report_troops(@page.search("#attack_info_def tr:eq(3) tr")[2])

      pillage,total = @page.search("#attack_results").text.scan(/(\d+)\/(\d+)/).flatten.map(&:to_i)

      report.full_pillage = pillage == total

      if (!@page.search('#attack_results').empty?)
        report.pillage = Resource.parse(@page.search('#attack_results td:first'))
      end

      if (!@page.search('#attack_spy_resources').empty?)
        report.resources = Resource.parse(@page.search('#attack_spy_resources td span[class!=grey]'))
      end
    end

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