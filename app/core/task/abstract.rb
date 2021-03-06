class Task::Abstract

  class << self
    attr_accessor :_performs_to,:_in_development,:_sleep,:_run_daily,:_queue
  end

  def self.run_daily hour
    self._run_daily = hour
  end

  def self.sleep? active
    self._sleep = active
  end

  def self.performs_to interval
    self._performs_to = interval
  end

  def self.in_development
    self._in_development = true
  end

  def self.init_schedules
    if (self == Task::Abstract || self._in_development == true)
      return 
    end

    obj = Delayed::Job.all.select{|a| YAML.load(a.handler).object.class == self }

    # raise "Non unique task #{self}" if (obj.size > 1)
    if (obj.size > 1)
      obj.shift
      obj.map(&:delete)
    end
    if (obj.empty?)
      self.new.delay.execute
    end
  end

  def test_local

    return if (!["kerrigan","kerrigan-linux","overmind","localhost"].include?(Socket.gethostname))

    loop {
      result = run
      sleep_for = result.to_time - Time.now
      puts "Dormir até #{result.to_time}"
      sleep(sleep_for < 0 ? 0 : sleep_for)
      system("notify-send wake-up")
    }
  end

  def execute
    info "Running #{self.class}"
    init = Time.zone.now.beginning_of_day + Config.sleep_mode.start(4).hours
    endd = init + Config.sleep_mode.duration(6).hours
    enable = Config.sleep_mode.enabled(true)
    
    if ((init..endd).cover?(Time.zone.now) && self.class._sleep != false && enable)
      self.class.new.delay(run_at: endd ,queue: 'normal_priority').execute
      return
    else
      result = self.run
    end

    Rails.logger.info("Task returned #{result}")

    returned_date = [ActiveSupport::TimeWithZone,DateTime].include?(result.class)

    Rails.logger.info("Returned date #{result.class}")
    
    # Rails.logger.info("run_daily: #{self.class._run_daily}")
    # Rails.logger.info("_performs_to && !returned_date: #{self.class._performs_to} && #{!returned_date}")
    # Rails.logger.info("run_daily: #{self.class._run_daily}")

    if (self.class._run_daily)
      Rails.logger.info("TEST:1")
      self.class.new.delay(run_at: Time.zone.now.beginning_of_day + 1.day + self.class._run_daily.hours ,queue: 'normal_priority').execute
    elsif (self.class._performs_to && !returned_date)
      Rails.logger.info("TEST:2")
      self.class.new.delay(run_at: Time.zone.now + self.class._performs_to ,queue: 'normal_priority').execute
    elsif ([ActiveSupport::TimeWithZone,DateTime].include?(result.class)) 
      Rails.logger.info("TEST:3 #{result}")
      self.class.new.delay(run_at: result ,queue: 'normal_priority').execute 
    else
      raise Exception.new("Invalid job state #{self.class}")
    end
  end

  def info *args
    Rails.logger.info args.join(' ')
  end

end
