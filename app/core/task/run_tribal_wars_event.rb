class Task::RunTribalWarsEvent < Task::Abstract

  def run
    screen = Screen::EventAssault.new
    Rails.logger.info("We have #{screen.mercenaries_amount} free in event")
    if (screen.mercenaries_amount > 0)
    	event = screen.best_event
    	Rails.logger.info("Best target for event is #{event}")
    	screen.put_mercenary(event)
    	return Time.zone.now
    else
        return screen.next_free_mercenary
    end
  end

end
