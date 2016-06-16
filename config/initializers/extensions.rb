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
          binding.pry if result < Time.now
          result =    result
      elsif scan(/... \d{1,2}, \d{4}/).size > 0 then
          result = Time.zone.parse self

      elsif scan(/\d+\.\d+\. .. \d+\:\d+/).size > 0 then  # ["22.09. às 13:45"]
          date,hour = self.split('. às ')
          date = date.split('.').concat([Time.now.year]).join('/').to_date
          result = Time.zone.parse("#{date} #{hour}")
      else
          binding.pry
      end
      result
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
end

class Array
  def pmap
    Parallel.map(self, in_processes: ENV["PMAP_THREADS"] || 1){ |i| yield(i) }
  end

  def pselect
    partial = pmap do |i| 
      yield(i) ? i : nil
    end

    partial.compact
  end
end