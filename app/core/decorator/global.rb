class Decorator::Global

	def html(page,request)
    if (!page.search('.menu_column').first.nil?)
      @my_villages = Village.my_cache.sort do |a,b|
        a.significant_name <=> b.significant_name
      end
  		create_menu(page,request)
  		create_arrows(page,request)
    end
		return page
	end

	def create_menu(page,request)
		current_village_id = (request.url.scan(/village=(\d+)/).flatten.first || @my_villages.first.vid).to_i

		html = %{
<tr>
  <td colspan="6">
    <table id="quickbar_inner" style="border-collapse: collapse;" width="100%">
      <tbody>
        <tr class="topborder">
          <td class="left"> </td>
          <td class="main"> </td>
          <td class="right"> </td>
        </tr>
        <tr>
          <td class="left"> </td>
          <td id="quickbar_contents" class="main">
            <ul class="menu quickbar">
              <li class="quickbar_item" data-hotkey="1">
                <span>
                  <a class="quickbar_link" href="/game.php?village=#{current_village_id}&screen=main">
                    <img class="quickbar_image" src="https://dsbr.innogamescdn.com/8.67/31781/graphic//buildings/main.png">Edifício principal
                  </a>
                </span>
              </li>
              <li class="quickbar_item" data-hotkey="2">
                <span>
                  <a class="quickbar_link" href="/game.php?village=#{current_village_id}&screen=train">
                    <img class="quickbar_image" src="https://dsbr.innogamescdn.com/8.67/31781/graphic//buildings/barracks.png">Recrutar
                  </a>
                </span>
              </li>
              <li class="quickbar_item" data-hotkey="3">
                <span>
                  <a class="quickbar_link" href="/game.php?village=#{current_village_id}&screen=snob">
                    <img class="quickbar_image" src="https://dsbr.innogamescdn.com/8.67/31781/graphic//buildings/snob.png">Academia
                  </a>
                </span>
              </li>
              <li class="quickbar_item" data-hotkey="4">
                <span>
                  <a class="quickbar_link" href="/game.php?village=#{current_village_id}&screen=smith">
                    <img class="quickbar_image" src="https://dsbr.innogamescdn.com/8.67/31781/graphic//buildings/smith.png">Ferreiro
                  </a>
                </span>
              </li>
              
              <li class="quickbar_item" data-hotkey="5">
                <span>
                  <a class="quickbar_link" href="/game.php?village=#{current_village_id}&screen=place">
                    <img class="quickbar_image" src="https://dsbr.innogamescdn.com/8.67/31781/graphic//buildings/place.png">Praça de reunião
                  </a>
                </span>
              </li>
              
              <li class="quickbar_item" data-hotkey="6">
                <span>
                  <a class="quickbar_link" href="/game.php?village=#{current_village_id}&screen=market">
                    <img class="quickbar_image" src="https://dsbr.innogamescdn.com/8.67/31781/graphic//buildings/market.png">Mercado
                  </a>
                </span>
              </li>
            </ul>
          </td>
          <td class="right"> </td>
        </tr>
        <tr class="bottomborder">
          <td class="left"> </td>
          <td class="main"> </td>
          <td class="right"> </td>
        </tr>
        <tr>
          <td class="shadow" colspan="3">
            <div class="leftshadow"> </div>
            <div class="rightshadow"> </div>
          </td>
        </tr>
      </tbody>
    </table>
  </td>
</tr>
		}

		page.search('#menu_row2').first.parents(6).add_previous_sibling(html)
	end

	def create_arrows(page,request)

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
	end

	# def create_menu(page,village,request)
	# 	menu = page.search('.menu_column tr').first.clone
	# 	menu.search('a').first.content = village.significant_name
	# 	menu.search('a').first.attributes['href'].value = request.original_url.gsub(/village=\d+/,"village=#{village.vid}")
	# 	menu
	# end


end