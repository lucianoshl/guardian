module ResourceHelper
  def render_resource resource
    %{
      <img src="https://help.tribalwars.com.br/images/2/20/Made.png"> #{resource.wood}
      <img src="https://help.tribalwars.com.br/images/8/8e/Argila.png"> #{resource.stone}
      <img src="https://help.tribalwars.com.br/images/3/32/Fero.png"> #{resource.iron}
    }.html_safe
  end
end
