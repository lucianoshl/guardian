class InfoPlayerController < InjectedController
  def show
  	@player = Player.where(pid: params["id"].to_i).first
  	if (@player.nil?)
  		@player = Player.unsaved_village(pid: params["id"].to_i)
  	end

  	add_tw_stats

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

  	img_node = Nokogiri::HTML::DocumentFragment.parse "<img src=\"http://br.twstats.com/#{@world}/image.php?type=playergraph&graph=points&id=#{@player.pid}\" />"

  	empty_cell.add_child img_node
  end

end
