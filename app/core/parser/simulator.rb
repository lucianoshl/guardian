class Parser::Simulator < Parser::Basic

	def parse screen
		super
		
		screen.losses = {}
		screen.has_losses = false
		screen.defs = Troop.new
		screen.defs_losses = Troop.new
		
		units =  @page.search('#simulation_result tr:eq(1) img').map{|a| a.attr('src').scan(/unit_(.+)\.png/)}.flatten
		origin_losses_qtes = @page.search('#simulation_result tr:eq(3) .unit-item').map(&:text).map(&:to_i)
		defs = @page.search('#simulation_result tr:eq(4) .unit-item').map(&:text).map(&:to_i)
		defs_losses = @page.search('#simulation_result tr:eq(5) .unit-item').map(&:text).map(&:to_i)



		units.each_with_index do |unit,index|
			screen.losses[unit] = origin_losses_qtes[index]
			screen.has_losses |= origin_losses_qtes[index] > 0


			screen.defs[unit] = defs[index]
			screen.defs_losses[unit] = defs_losses[index]
		end

		screen.losses = Troop.new screen.losses


		screen.defs_remaining = screen.defs - screen.defs_losses
	end

end