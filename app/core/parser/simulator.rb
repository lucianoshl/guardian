class Parser::Simulator < Parser::Basic

	def parse screen
		super
		
		screen.losses = {}
		# screen.form = @page.form
		screen.has_losses = false

		units =  @page.search('#simulation_result tr:eq(1) img').map{|a| a.attr('src').scan(/unit_(.+)\.png/)}.flatten
		origin_losses_qtes = @page.search('#simulation_result tr:eq(3) .unit-item').map(&:text).map(&:to_i)


		units.each_with_index do |unit,index|
			screen.losses[unit] = origin_losses_qtes[index]
			screen.has_losses |= origin_losses_qtes[index] > 0
		end

		screen.losses = Troop.new screen.losses
	end

end