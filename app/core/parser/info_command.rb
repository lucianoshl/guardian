class Parser::InfoCommand < Parser::Basic

  def parse(screen)
    super
    origin_id,target_id = @page.search('#content_value a').to_xml.scan(/info_village.*?id=(\d+)/).flatten.map(&:to_i)

    screen.origin = Village.where(vid: origin_id).first
    screen.target = Village.where(vid: target_id).first
  end

end