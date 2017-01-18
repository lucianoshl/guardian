class Decorator::Map

	def raw(page)
	    json = JSON.parse(page.scan(/TWMap.sectorPrefech = (.*);/).first.first)
	    json = TribalWarsController.new.convert_map_json(json)
	    page.gsub(page.scan(/TWMap.sectorPrefech = (.*);/).first.first,json.to_json)
	end

end