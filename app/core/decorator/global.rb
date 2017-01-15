class Decorator::Global

	def html(page,request)

		@my_villages = Village.my_cache.sort do |a,b|
			a.significant_name <=> b.significant_name
		end

		current_village_id = (request.url.scan(/village=(\d+)/).flatten.first || @my_villages.first.vid).to_i

		current_village = @my_villages.select{|a| a.vid == current_village_id}.first

		index = @my_villages.index(current_village)

		left = @my_villages[index-1]
		right = @my_villages[index+1] 

		left = %{
			<td class="box-item icon-box separate arrowCell">
				<a 
					id="village_switch_left" 
					class="village_switch_link" 
					href="#{request.url.gsub(current_village_id.to_s,left.vid.to_s)}" accesskey="a">
				<span class="arrowLeft"> </span>
				</a> 
			</td>
		}
		right = %{
			<td class="box-item icon-box arrowCell">
				<a 
					id="village_switch_right"
					class="village_switch_link"
					href="#{request.url.gsub(current_village_id.to_s,right.vid.to_s)}" accesskey="d">
					<span class="arrowRight"> </span>
				</a>
			</td>
		}

		page.search('#menu_row2_village').first.add_previous_sibling(left)
		page.search('#menu_row2_village').first.add_previous_sibling(right)



						
		# if (!page.search('.menu_column').first.nil?)
		# 	clone_menu = page.search('.menu_column').first.clone
		# 	clone_menu.search('.menu-column-item').map(&:parent).map(&:remove)
		# 	# clone_menu_item = clone_menu.search('td').first
		# 	# clone_menu.search('td').remove

		# 	# page.search('a[href*=overview_villages]').first.parent.add_child(clone_menu)
		# 	.map do |village|
		# 		clone_menu.search('.bottom').first.before(create_menu(page,village,request))
		# 	end

		# 	# binding.pry
		# 	page.search('a[href*=overview_villages]').first.parent.add_child(clone_menu)
		# 	# page.search('.menu_column').first.remove
		# end



		return page
	end

	def create_menu(page,village,request)
		menu = page.search('.menu_column tr').first.clone
		menu.search('a').first.content = village.significant_name
		menu.search('a').first.attributes['href'].value = request.original_url.gsub(/village=\d+/,"village=#{village.vid}")
		menu
	end

end