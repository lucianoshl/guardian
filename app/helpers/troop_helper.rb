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
end
