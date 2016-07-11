class Config
  include Mongoid::Document

  field :name, type: String
  field :section, type: String
  field :_object, type: String
  field :clazz, type: String

  def self.method_missing(m, *args, &block) 
    return Config.new(section: m)
  end  

  def method_missing(m, *args, &block) 
    conf = self.class.where(section: section,name: m).first || Config.new(section: section,name: m)
    
    conf.value = conf.value.nil? ? args.first : conf.value
    conf.save
    conf.value
  end  

  def value=(val)
    self.clazz = val.class
    self._object = YAML.dump(val) if (!val.nil?)
  end

  def value
    return nil if (_object.nil?)
    YAML.load(_object)
  end
end
