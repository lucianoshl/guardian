class Parser::Simulator < Parser::Basic

	def parse screen
		super
		
		screen.losses = {}
		# screen.form = @page.form
		screen.has_losses = false

		has_result = !@page.search('th[width="35"]').first.nil?
		if (has_result) then
			lines = @page.search('th[width="35"]').first.parents(2).search('tr')

			units = (lines.first.search('img').map { |i| i.attr('src').scan(/unit_(.*)\./) }).flatten

			units.each_with_index do |unit, index|
				loses = lines[2].search('td')[index + 1].extract_number
				screen.losses[unit.to_sym] = loses
				screen.has_losses |= loses > 0
			end
		end

		screen.losses = Troop.new screen.losses
	end

end