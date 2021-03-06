class Task::RunTribalWarsEvent < Task::Abstract

  def run
    # event = get_current_event
    # binding.pry
    # screen = Screen::AllyContracts.new
    # binding.pry
    # screen = Screen::EventAssault.new
    # Rails.logger.info("Event enable: #{screen.enabled}".white.on_blue)
    # if (!screen.enabled)
    #     return Time.zone.now + 1.month
    # end
    # Rails.logger.info("We have #{screen.mercenaries_amount} free in event")
    # if (screen.mercenaries_amount > 0)
    # 	event = screen.best_event
    # 	Rails.logger.info("Best target for event is #{event}")
    # 	screen.put_mercenary(event)
    # 	return Time.zone.now
    # else
    #     return screen.next_free_mercenary
    # end
    return Time.zone.now + 1.day
  end


  def get_current_event
    events = [Screen::EventAssault,Screen::Crest]
    events = events.select do |event|
        begin
            event.new
            true
        rescue
            false
        end
    end
    events.compact.first
  end

end
