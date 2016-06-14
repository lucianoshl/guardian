module VillageHelper
  def render_village_small(village)
    local = village.x/100.floor * 10 + village.y/100.floor
    label = "#{village.name} (#{village.x}|#{village.y}) K#{local}"
    link_to label, controller: "village", action: "show", id: village
  end
end
