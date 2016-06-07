class Task::PlayerMonitor < Task::Abstract

  def run
    system("notify-send '#{Time.zone.now}'")
  end

end