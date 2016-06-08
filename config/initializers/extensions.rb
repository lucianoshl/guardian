class Object  
  def extract_number
      to_s.scan(/\d+/).join.to_i
  end
end

class Mechanize
    def inspect
        self.class.name
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