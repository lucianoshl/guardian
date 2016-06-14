module TroopHelper
  def render_troops(troops,complete=true)
    troops = troops.to_h

    (troops.map do |unit,qte|
      %{
        <span>
          <img src="https://dsbr.innogamescdn.com/8.48/29600/graphic/unit/unit_#{unit}.png"/> #{qte}
        </span>
      }
    end).join.html_safe

  end
end
