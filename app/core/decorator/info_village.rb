class Decorator::InfoVillage

  def html(page)
    link_element = page.search('a[href*=target]').first
    existing_player = !link_element.nil?

    if (existing_player)
      village_id = link_element.attr('href').scan(/target=(\d+)/).first.first.extract_number
      insert_tw_stats(page,village_id)
    end

    return page
  end


  def insert_tw_stats(page,village_id)
    link = page.search('a[href*=beacon]').first



    base_element = link.parents(2).clone

    tw_stats_link = base_element.search('a').first

    tw_stats_link.content = ' Ver no TWStatus'
    tw_stats_link.attributes['href'].value = "http://br.twstats.com/#{User.current.world}/index.php?page=village&id=#{village_id}"
    tw_stats_link.set_attribute('target','_blank')
    tw_stats_link.children.first.before(link.search('span').first.clone)


    link.parents(3).search('tr').last.after(base_element)
  end

end