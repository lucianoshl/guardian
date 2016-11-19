class Job::Abstract

  class << self
    attr_accessor :_queue
  end

  include Mongoid::Document
  field :state, type: String, default: 'starting'
  field :priority, type: String, default: 'normal_priority'

  has_one :active_job, class_name: "Delayed::Backend::Mongoid::Job", :dependent => :destroy


  def self.queue queue
    self._queue = queue
  end

  def self.init_schedules
  end

  def change_state(state)
    self.state = state
    self.save
  end

  def schedule_job(date = nil)
      self.active_job = self.delay(queue: self.priority).run if date.nil?
      self.active_job = self.delay(run_at: date,queue: self.priority).run if !date.nil?
      self.save
  end

  def run
    Rails.logger.info("Running job #{self.class.name}: start")
    Rails.logger.info("Job state: #{self.state}")

    if self.state.eql? 'starting'
      change_state('scheduled')
      schedule_job

    elsif self.state.eql? 'scheduled'
      change_state('running')
      begin
      result = self.execute
      rescue Exception => e
        change_state('error')
        raise e
      end
      change_state('scheduled')
      schedule_job(result) if !result.eql?(remove_job)
      self.delete if result.eql? remove_job

    elsif self.state.eql? 'paused'
      schedule_job(5.minutes.from_now)
    end

    Rails.logger.info("Running job #{self.class.name}: end")
  end

  def remove_job
    :remove_job
  end

  after_save do
    
    if (!self.class._queue.nil? && self.priority != self.class._queue.to_s)
      self.priority = self.class._queue
      self.save
    end

    if self.state.eql?('starting')
      self.run
    end
  end

end