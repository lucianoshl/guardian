class Parser::InfoCommand < Parser::Basic

  def parse(screen)
    super
    origin_id,target_id = @page.search('#content_value a').to_xml.scan(/info_village.*?id=(\d+)/).flatten.map(&:to_i)

    deleted_village = @page.search('h2').text.include?("A aldeia não existe mais")

    screen.target = Village.where(vid: target_id).first
    screen.origin = Village.where(vid: origin_id).first

    if (screen.target.nil? && !deleted_village)
      screen.target = Screen::InfoVillage.new(id:target_id).village
      screen.target.save
    end
  end

end