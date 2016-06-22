class Config
  include Mongoid::Document

  field :name, type: String
  field :section, type: String
  field :_object, type: String

  def self.method_missing(m, *args, &block) 
    return Config.new(section: m)
  end  

  def method_missing(m, *args, &block) 
    conf = self.class.where(section: section,name: name).first || Config.new(section: section,name: name)
    
    conf.value = conf.value || args.first
    conf.save
    conf.value
  end  

  def value=(val)
    self._object = YAML.dump(val) if (!val.nil?)
  end

  def value
    return nil if (_object.nil?)
    YAML.load(_object)
  end
end
