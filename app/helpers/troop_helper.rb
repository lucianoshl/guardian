module TroopHelper
  def render_troops(troops,complete=true)
    troops = troops.to_h

    if (!complete)
      troops = (troops.select do |unit,qte|
        qte != 0
      end).to_h
    end

    (troops.map do |unit,qte|
      %{
        <span>
          <img src="https://dsbr.innogamescdn.com/8.48/29600/graphic/unit/unit_#{unit}.png"/> #{qte}
        </span>
      }
    end).join.html_safe
  end

  def render_troops_grid(troops,units)
    troops = troops.to_h
    units = units.map(&:to_s)

    troops = (troops.select do |unit,qte|
      units.include?(unit)
    end).to_h

    header = (troops.map do |unit,qte|
      %{ <th><img src="https://dsbr.innogamescdn.com/8.48/29600/graphic/unit/unit_#{unit}.png"/></th> }
    end).join

    line = (troops.map do |unit,qte|
      %{ <td>#{qte}</td> }
    end).join

    result = "<table class='unit-table'><tr>#{header}</tr><tr>#{line}</tr></table>".html_safe
  end
end
