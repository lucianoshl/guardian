class Cookie
  include Mongoid::Document

  field :content_yaml, type: String
  field :created_at, type: Date
  belongs_to :user

  def content= object
    self.content_yaml = YAML.dump(object)
  end

  def content
    YAML.load(content_yaml)
  end

  def self.latest
    last = Cookie.desc(:created_at).to_a.first
    last.nil? ? nil : last.content
  end

end
