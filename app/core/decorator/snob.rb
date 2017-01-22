class Decorator::Snob

	def html(page)
		# coin_cost =  page.search('.mint_coins_req').text.strip.split("\n").map(&:extract_number).to_resource
		# current = page.search('.header-border.menu_block_right').first.text.split.to_resource

		# missing = coin_cost - current

		# if (missing.has_positive?)
		# 	element = page.search('.mint_coins_req').first.parents(2).search('.inactive').first
		# 	element.content = ""
		# 	element.add_next_sibling(missing.to_html)
		# 	table_title = page.search('.mint_coins_req').first.parents(3).search('th').last
		# 	table_title.content = "Falta"
		# end

		return page
	end

end