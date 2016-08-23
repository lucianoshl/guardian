class Job::Base

  include Mongoid::Document
  field :state, type: String, default: 'starting'

  has_one :active_job, class_name: "Delayed::Job"

  class << self
    attr_accessor :_run_daily,:_in_development
  end

  def self.run_daily hour
    self._run_daily = hour
  end

  def self.in_development
    self._in_development = true
  end

  def self.init_schedules
    return if self == Job::Base
    return if self._in_development
    return if !self.count.zero?

    job = self.new
    job.schedule_now
  end

  def execute
    puts "Running #{self.class}"
    init = Time.zone.now.beginning_of_day + Config.sleep_mode.start(4).hours
    endd = init + Config.sleep_mode.duration(6).hours
    enable = Config.sleep_mode.enabled(true)
    
    if ((init..endd).cover?(Time.zone.now) && self.class._sleep != false && enable)
      schedule(endd)
      return
    else
      result = self.run
    end
    
    if (self.class._run_daily)
      schedule(Time.zone.now.beginning_of_day + 1.day + self.class._run_daily.hours)
    elsif (self.class._performs_to)
      schedule(Time.zone.now + self.class._performs_to)
    elsif ([ActiveSupport::TimeWithZone,DateTime].include?(result.class)) 
      schedule(result)
    else
      raise Exception.new("Invalid job state #{self.class}")
    end
  end

  def schedule_now
    schedule(Time.zone.now)
  end

  def schedule(time)
    self.save
    self.active_job.delete if (!self.active_job.nil?)
    self.active_job = self.delay(run_at: time).execute
    self.save!
  end

end