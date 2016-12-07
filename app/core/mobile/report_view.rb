class Mobile::ReportView < Mobile::Base

	entry 'm.php'
	end_point '' 
	url mode: 'report'

	attr_accessor :report

	def parse page
		@units = page.search("#attack_info_att tr:eq(3) img").map{|i| i.attr('src').scan(/unit_(.+)\./) }.flatten

		self.report = report = Report.new

		report.rid = page.uri.to_s.scan(/id=(\d+)/).extract_number

		report.moral = page.search('#attack_luck').first.next.next.text.extract_number
		report.luck = page.search('#attack_luck').text.strip.scan(/\d+\.\d+/).first.to_f

		color = page.search('img[src*=dots]').first.attr('src').scan(/dots\/(.+)\.png/).first.first
		enum = {
			blue: "spy",
			green: "win",
			yellow: "win_lost",
			red: "lost",
			red_blue: "spy_lost",
			error: "unknown"
		}
 
		report.status = enum[color.to_sym] || "error"

		target_id = page.search('#attack_info_def .village_anchor').attr('data-id').value

		begin
			report.target = Village.find_by(vid: target_id)
		rescue Mongoid::Errors::DocumentNotFound => e
			pp = Screen::InfoVillage.new(id: target_id)
			report.target = pp.village.db_merge
		end
		
		begin
			report.origin = Village.where(vid: page.search('#attack_info_att .village_anchor').attr('data-id').value).first
		rescue => e
			raise Exception.new("Erro ao parsear o report #{page.uri}")
		end

		report.occurrence = page.search('.report_table > tr > td').text.parse_datetime

		report.origin_troops = parse_report_troops(page.search("#attack_info_att_units tr")[1])
		report.origin_troops_losses = parse_report_troops(page.search("#attack_info_att_units tr")[2])

		if (report.status != :lost) 

			if (page.search('table[id*=attack_spy_buildings]').size > 0) 
				report.target_buildings = {}
				page.search('table[id*=attack_spy_buildings]').search('img').each do |img|
					house = img.attr('src').scan(/\/([a-z]*).png/).flatten.first
					report.target_buildings[house] = img.parents(2).search('td').last.extract_number
				end
			end

			content = page.search("#attack_info_def tr:eq(3) tr")[1]
			report.target_troops = parse_report_troops(content) if (!content.nil?)
			content = page.search("#attack_info_def tr:eq(3) tr")[2]
			report.target_troops_losses = parse_report_troops(content) if (!content.nil?)
			if (page.search('#attack_spy_away').size > 0)
				report.target_troops_away = parse_report_troops(page.search('#attack_spy_away'))
			end

			pillage,total = page.search("#attack_results").text.scan(/(\d+)\/(\d+)/).flatten.map(&:to_i)

			report.full_pillage = pillage == total

			if (!page.search('#attack_results').empty?)
				report.pillage = Resource.parse(page.search('#attack_results td:first'))
			end

			if (!page.search('#attack_spy_resources').empty?)
				report.resources = Resource.parse(page.search('#attack_spy_resources td span[class!=grey]'))
			end

			attack_result_itens = page.search('#attack_results > tr')

			if (attack_result_itens.size > 1)
				try_ram = attack_result_itens.text.scan(/caiu de (\d+) para (\d+)/).flatten
				if (try_ram.size > 0)
					report.wall_destroyed = try_ram.map(&:to_i)
				end

				try_loyalty = attack_result_itens.text.scan(/Descida (\d+) para (\-{0,1}\d+)/).flatten
				if (try_loyalty.size > 0)
					report.loyalty_destroyed = try_loyalty.map(&:to_i)
				end

			end

			if (!page.search("#attack_info_att > tr")[3].nil?)
				report.origin_flag =  page.search("#attack_info_att > tr")[3].search('td:last').text.strip
			end

			if (!page.search("#attack_info_def > tr")[3].nil?)
				report.target_flag =  page.search("#attack_info_def > tr")[3].search('td:last').text.strip
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

	def before_request args
		args
	end
end
