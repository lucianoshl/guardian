class Screen::StatsOwn < Screen::Basic

  attr_accessor :graph_loot

  url screen: 'info_player', mode: 'stats_own'
end