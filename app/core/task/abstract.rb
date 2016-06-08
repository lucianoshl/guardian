class Task::Abstract

  class << self
    attr_accessor :_performs_to
  end

  def self.performs_to interval
    self._performs_to = interval
  end

  def self.init_schedule
    if (self == Task::Abstract)
      return 
    end
    obj = Delayed::Job.all.select{|a| YAML.load(a.handler).object.class == self }
    raise "Non unique task" if (obj.size > 1)
    if (obj.empty?)
      self.new.delay.execute
    end
  end

  def execute
    self.run
    if (self.class._performs_to)
      self.class.new.delay(run_at: Time.zone.now + self.class._performs_to).execute
    end
  end

end