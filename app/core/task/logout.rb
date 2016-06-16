class Task::Logout < Task::Abstract

  performs_to 2.hour

  def run
    if (rand(3) == 1)
      place = Screen::Place.new
      place.logout
    end
  end

end
