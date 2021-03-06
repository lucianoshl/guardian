class Object  
  def extract_number
      to_s.scan(/\d+/).join.to_i
  end
  def to_coordinate
      values = to_s.scan(/(\d{3})\|(\d{3})/).flatten
      OpenStruct.new({ x: values[0].to_i, y: values[1].to_i })
  end
  def parse_datetime
      result = nil
      begin
        if self.include?('hoje')
            formated = gsub(/hoje ../, Date.today.to_s)
            result = Time.zone.parse(formated)
        elsif self.include?('amanhã') then
            tomorrow = Date.today + 1.day
            formated = gsub(/amanhã ../, tomorrow.to_s)
            result =    Time.zone.parse(formated)
        elsif self.include?('em') then
            date = scan(/em (\d+)\.(\d+)\./).flatten.concat([Time.now.year]).join('/').to_date
            hour = scan(/\d+\:\d+/).flatten.first
            result = Time.zone.parse("#{date} #{hour}")
            raise Exception.new("result < Time.now") if result < Time.now
            result =    result
        elsif scan(/... \d{1,2}, \d{4}/).size > 0 then
            raw = self.gsub('Set','Sep').gsub('Out','Oct').gsub('Dez','Dec').gsub('Fev','Feb')
            result = DateTime.strptime(raw,"%b %d, %Y %H:%M:%S")
            result = result.to_datetime.change(offset: Time.zone.now.strftime("%z"))

        elsif scan(/\d+\.\d+\. .. \d+\:\d+/).size > 0 then  # ["22.09. às 13:45"]
            date,hour = self.split('. às ')
            date = date.split('.').concat([Time.now.year]).join('/').to_date
            result = Time.zone.parse("#{date} #{hour}")
        else
            raise Exception.new("unsupported parse_datetime date") 
        end
      rescue Exception => e
        raise Exception.new("Error parsing date #{self} #{e} #{e.message}")
      end
      result
  end
end

class Delayed::Job

  belongs_to :job, class_name: "Job::Abstract", optional: true

  after_save do
    if (!self.job.nil?)
      self.job.scheduled = self.run_at
    end
  end

  def run_now(unlock=false)
    self.run_at = Time.zone.now
    self.attempts = 0
    if (unlock)
      self.locked_at = nil
      self.locked_by = nil
      self.last_error = nil
    end
    self.save
  end
end

class Mechanize
    def inspect
        self.class.name
    end

    def add_cookies cookies
      if (!cookies.nil?)
        self.cookie_jar.clear!
        cookies.each do |c|
          self.cookie_jar.add!(c)
        end
      end
      return self
    end

    def self.my
      m = Mechanize.new
      # m.user_agent_alias = 'iPhone'
      m
    end
end

module Mongoid::Document
  def my_fields
    result = fields
    result.delete('_id')
    result.delete('_type')
    result = result.map{|k,v| v.name }
  end
end

class Mechanize::Form
  def fill map
    map.each do |key,value|
      self[key.to_s] = value
    end
  end
end

class Mechanize::Page
  def show_in_browser
    file = '/tmp/page.html'
    File.open(file, 'w') { |file| file.write(self.body.force_encoding('iso-8859-1').encode('utf-8')) }
  end
end

class Nokogiri::XML::Element
  def parents(size)
    result = self
    (0..size - 1).each do |_variable|
      result = result.parent
    end
    result
  end

  def replace_html=(html)
    # self.content = html
    self.parent.add_child(html)
  end
end

class Array
  def pmap
    # parameter = ENV["PMAP_THREADS"].nil? ? 1 : ENV["PMAP_THREADS"].to_i
    parameter = 3
    Parallel.map(self, in_threads: parameter || 1){ |i| yield(i) }
  end

  def pselect
    partial = pmap do |i| 
      yield(i) ? i : nil
    end

    partial.compact
  end
end

class Time
  def in_sleep?
    interval = 8.hours
    offset_from_zero = 2.hours

    init = Time.zone.now.beginning_of_day + offset_from_zero
    endd = init + interval
    (init..endd).cover?(self)
  end
end

class ActiveSupport::TimeWithZone
  def render 
    strftime("%d/%m - %H:%M:%S")
  end
end

module System

  def self.clean
    (Mongoid.models - [User,Property::Simple,Property::InvitedUser,Property::InviteUrl]).map{|a| a.all.delete}
    Rails.cache.clear
  end

  def self.reset
    Mongoid.models.map{|a| a.all.delete}
    Rails.cache.clear
  end

end

# http://www.rebeccamiller-webster.com/2012/06/recursively-convert-a-ruby-hash-to-openstruct/
class Hash

  def with_sym_keys
    self.inject({}) { |memo, (k,v)| memo[k.to_sym] = v; memo } 
  end

  #   :exclude => [keys] - keys need to be symbols 
  def to_struct(options = {})
    convert_to_ostruct_recursive(self, options) 
  end

  private
    def convert_to_ostruct_recursive(obj, options)
      result = obj
      if result.is_a? Hash
        result = result.dup.with_sym_keys
        result.each  do |key, val| 
          result[key] = convert_to_ostruct_recursive(val, options) unless options[:exclude].try(:include?, key)
        end
        result = OpenStruct.new result       
      elsif result.is_a? Array
         result = result.map { |r| convert_to_ostruct_recursive(r, options) }
      end
      return result
    end
end


class InexistentVillage < Exception
end

TimeType = GraphQL::ScalarType.define do
  name "Time"
  description "Time since epoch in seconds"

  coerce_input ->(value, ctx) {  Time.at(Float(value)) }
  coerce_result ->(value, ctx) { value.to_f * 1000 }
end

def field_mapping(types,mongo_type)
  field_mapping = {}
  field_mapping[BSON::ObjectId] = !types.ID
  field_mapping[Integer] = types.Int
  field_mapping[String] = types.String
  field_mapping[Time] = TimeType
  field_mapping[mongo_type]
end