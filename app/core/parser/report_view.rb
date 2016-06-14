class Parser::ReportView < Parser::Basic

  def parse(screen)
    super
    screen.report = report = Report.new

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

    if (report.status != :lost) 
        report.target_buildings = {}

        @page.search('table[id*=attack_spy_buildings]').search('img').each do |img|
            house = img.attr('src').scan(/\/([a-z]*).png/).flatten.first
            report.target_buildings[house] = img.parents(2).search('td').last.extract_number
        end

        report.target_troops = {}
        lines = @page.search('#attack_info_def_units td[width="35"]').first.parents(2).search('tr')

        units = (lines.first.search('img').map { |i| i.attr('src').scan(/unit_(.*)\./) }).flatten

        @page.search('#attack_spy_resources td span').to_a

        units.each_with_index do |unit, index|
            loses = lines[1].search('td')[index + 1].extract_number
            report.target_troops[unit.to_sym] = loses
        end
        pillage,total = @page.search("#attack_results").text.scan(/(\d+)\/(\d+)/).flatten.map(&:to_i)

        report.full_pillage = pillage == total


        if (!@page.search('#attack_spy_resources').empty?)
            report.resources = Resource.parse(@page.search('#attack_spy_resources td span[class!=grey]'))
        end
    end

  end

end