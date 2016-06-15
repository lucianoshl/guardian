module VillageHelper
  def render_village_small(village)
    local = village.x/100.floor * 10 + village.y/100.floor
    label = "#{village.name} (#{village.x}|#{village.y}) K#{local}"
    link_to label, controller: "village", action: "show", id: village
  end

  def render_buildings(buildings)
    (buildings.map do |buildings,qte|
      %{
        <img src="https://dsbr.innogamescdn.com/8.48/29600/graphic/buildings/#{buildings}.png" /> #{qte}
      }
    end).join.html_safe
  end
end
