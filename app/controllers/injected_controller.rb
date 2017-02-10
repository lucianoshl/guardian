class InjectedController < ActionController::Base

  def process_headers(headers)
    headers = request.headers.to_h.select {|k,v| k.include?('HTTP_')}
    headers = (headers.map do |k,v|
      [k.gsub('HTTP_','').titleize.gsub(' ','-'),v]
    end).to_h

    headers.delete('Host')
    headers.delete('Referer')
    headers.delete('Cookie')
    return headers
  end

  def process_page(doc)

    decorator_name = 'Decorator::'+@screen.camelize
    begin
      Rails.logger.info("Decorator name : #{decorator_name}")
      decorator = decorator_name.constantize.new
    rescue
    end

    Village.my_cache.pmap do |village|
      title = doc.search('title').first
      if (!title.content.scan("#{village.name} (#{village.x}|#{village.y})").empty?)
        title.content = title.content.gsub(village.name,village.significant_name)
      end

      doc.search("a[href*='#{village.vid}']").map do |element|
        wrapper = element.search("*:contains('#{village.name}')").first

        if (!wrapper.nil?)
          wrapper.content = wrapper.content.gsub(village.name,village.significant_name)
        elsif (element.text.include?(village.name))
          element.content = element.content.gsub(village.name,village.significant_name)
        end
      end
    end

    decorator.html(doc) if (decorator.respond_to?("html"))

    Decorator::Global.new.html(doc,request)

    return doc
  end

  def generate_template doc
    @original_content = doc.search('#content_value').first.clone
    @original_content.name = 'div'
    @original_content.remove_attribute('id')

    doc.search('#content_value').first.content = ''

    template = doc.to_html

    template = template.gsub("content_value\"><","content_value\" class=\"custom-page\"><%= yield %><")
    

    file = Tempfile.new('template')
    file.write(template.force_encoding('UTF-8'))
    file.rewind
    file.close
    tmp_root = "#{Rails.root}/app/views/layouts/tmp"
    Dir.mkdir(tmp_root) if !File.exists?(tmp_root)
    FileUtils.mv(file.path,tmp_root)
    @template_file = "#{Rails.root}/app/views/layouts/tmp/#{file.path.split('/').last}"

    self.class.layout "tmp/#{file.path.split('/').last}"
  end

  before_filter do 
    @mode = request.params[:mode] || 'default'
    @screen = request.params[:screen] || 'default'
    @vid = request.url.scan(/village=(\d+)/).first.first.to_i
    @tw_path = "https://#{User.current.world}.tribalwars.com.br" + request.fullpath
    
    page = client.send(:get,@tw_path, process_headers(headers) )
    doc = Nokogiri::HTML(page.content)
    @doc = process_page(doc)
    generate_template(@doc)
  end

  after_filter do
    FileUtils.rm( @template_file )
  end

  def render *args
    page = args.first
    super
  end

  def client
    Client::Logged.new
  end

end
