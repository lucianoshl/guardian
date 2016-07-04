class Task::RemoveTroops < Task::Abstract

  in_development

  def run
    screen = Screen::Place.new
    next_attack = screen.incomings.first
    remove_troops(screen.village)
  end

  def remove_troops(village)
    screen = Screen::Place.new(id: village.vid)
    closer = (Village.all - Village.my).to_a.map.sort{|a,b| a.distance(village) <=> b.distance(village)}.first

    command = screen.send_support(closer,screen.units)

    sleep 60
    cancel_command(village,command)
  end


  def cancel_command(village,command)
    Mechanize.my.add_cookies(Cookie.latest).get("http://#{User.current.world}.tribalwars.com.br/#{command.cancel_url}")
  end

end
