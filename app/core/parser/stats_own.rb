class Parser::StatsOwn < Parser::Basic

  def parse screen
    screen.graph_loot = JSON.parse(@page.body.scan(/graph_loot(?:.|\n)*graph_loot/).first.scan(/data: (\[\[.*\]\])/).first.first)
  end
end