class InfoPlayerController < InjectedController

  include VillageHelper

  def show
  	# @player = Player.where(pid: params["id"].to_i).first
  	@player = OpenStruct.new 
  	@player.pid = params["id"].to_i
  	# if (@player.nil?)
  	# 	@player = Player.unsaved(pid: params["id"].to_i)
  	# end

  	add_tw_stats
  	add_my_villages

  end

  def add_tw_stats
  	line = @original_content.search('#player_info tr').last
  	line.add_next_sibling(%{
  		<td colspan=\"2\" style=\"text-align: center\" >
  			<a href=\"http://br.twstats.com/#{@world}/index.php?page=player&id=#{@player.pid}\">
  				TwStats
  			</a>
  		</td>})

  	empty_cell = @original_content.search("td[style='width: 50%']").last

  	img_node = Nokogiri::HTML::DocumentFragment.parse "<img width=\"100%\" src=\"http://br.twstats.com/#{@world}/image.php?type=playergraph&graph=points&id=#{@player.pid}\" />"

  	empty_cell.children.before img_node
  end


  def add_my_villages
  	table = @original_content.search('#villages_list').first
  	table.search('thead th').last.add_next_sibling('<th>Vizinho</th>')
  	table.search('thead th').last.add_next_sibling('<th>Distância</th>')

  	table.search('tbody > tr').map do |tr|
			next if (tr.text.include?('Exibir'))
  		current = tr.text.scan(/\d{3}\|\d{3}/).first.to_coordinate
  		vid = tr.search('a').first.attr('href').scan(/id=(\d+)/).first.first.to_i
  		closest = Village.my_cache.to_a.sort{|a,b| a.distance(current) <=> b.distance(current)}.first
  		tr.search(' > td').last.add_next_sibling("<td>#{render_village_small(closest,screen:'place',target:vid)}</td>")
  		tr.search(' > td').last.add_next_sibling("<td>#{closest.distance(current).round(2)}</td>")
  	end

  	lines = table.search('tbody > tr').map(&:clone)
  	table.search('tbody').first.content = ""

  	lines = lines.sort do |a,b|
  		a.search('td').last.text.to_f <=> b.search('td').last.text.to_f
  	end

  	lines.each { |a| table.search('tbody').first.add_child(a) }
  	
  	
  end

end
