class Task::Abstract

  class << self
    attr_accessor :_performs_to,:_in_development
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
    raise "Non unique task" if (obj.size > 1)
    if (obj.empty?)
      self.new.delay.execute
    end
  end

  def execute
    result = self.run
    binding.pry
    if (self.class._performs_to)
      self.class.new.delay(run_at: Time.zone.now + self.class._performs_to).execute
    elsif (result.class == DateTime) 
      self.class.new.delay(run_at: result).execute
    else
      raise Exception.new("Invalid job state #{self.class}")
    end
  end

  def info *args
    puts args.join(' ')
  end

end