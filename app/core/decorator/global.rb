class Decorator::Global

	def html(page,request)
		clone_menu = page.search('.menu_column').first.clone
		clone_menu.search('.menu-column-item').map(&:parent).map(&:remove)
		# clone_menu_item = clone_menu.search('td').first
		# clone_menu.search('td').remove

		# page.search('a[href*=overview_villages]').first.parent.add_child(clone_menu)
		Village.my.map do |village|
			clone_menu.search('.bottom').first.before(create_menu(page,village,request))
		end

		# binding.pry
		page.search('a[href*=overview_villages]').first.parent.add_child(clone_menu)
		# page.search('.menu_column').first.remove
		return page
	end

	def create_menu(page,village,request)
		menu = page.search('.menu_column tr').first.clone
		menu.search('a').first.content = village.significant_name
		menu.search('a').first.attributes['href'].value = request.original_url.gsub(/village=\d+/,"village=#{village.vid}")
		menu
	end

end