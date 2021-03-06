class Parser::StatsOwn < Parser::Basic

  def parse screen
    super
    screen.graph_loot = []
    if (@page.body.scan(/graph_loot(?:.|\n)*graph_loot/).size > 0)
      screen.graph_loot = JSON.parse(@page.body.scan(/graph_loot(?:.|\n)*graph_loot/).first.scan(/data: (\[\[.*\]\])/).first.first)
    end
  end
end