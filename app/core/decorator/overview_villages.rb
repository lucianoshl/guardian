class Decorator::OverviewVillages

	def html(page)
		to_sort = page.search('.row_a,.row_b')
		page.search('.row_a,.row_b').remove

		to_sort = to_sort.sort do |a,b|
			a.search('td').first.text.strip <=> b.search('td').first.text.strip
		end

		to_sort.map do |line|
			page.search('#production_table').first.add_child(line)
        end

		return page
	end

end