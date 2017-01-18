class InjectedController < ActionController::Base

  

  before_filter do 
    @vid = request.url.scan(/village=(\d+)/).first.first.to_i

    target_url = request.fullpath
    base = "https://#{User.current.world}.tribalwars.com.br"
    uri = base + target_url

    headers = request.headers.to_h.select {|k,v| k.include?('HTTP_')}
    headers = (headers.map do |k,v|
      [k.gsub('HTTP_','').titleize.gsub(' ','-'),v]
    end).to_h

    headers.delete('Host')
    headers.delete('Referer')
    headers.delete('Cookie')
    page = client.send(:get,uri,headers)

    doc = Nokogiri::HTML(page.content)

    doc.search('#content_value').first.content = ''

    template = doc.to_html

    template = template.gsub("content_value\"><","content_value\"><%= yield %><")

    file = Tempfile.new('template')
    file.write(template.force_encoding('UTF-8'))
    file.rewind
    file.close
    tmp_root = "#{Rails.root}/app/views/layouts/tmp"
    FileUtils.mv(file.path,tmp_root)
    Dir.mkdir(tmp_root) if !File.exists?(tmp_root)
    @template_file = "#{Rails.root}/app/views/layouts/tmp/#{file.path.split('/').last}"

    self.class.layout "tmp/#{file.path.split('/').last}"
  end

  after_filter do
    FileUtils.rm(@template_file )
  end

  def render *args
    page = args.first
    super
  end

  def client
    Client::Logged.new
  end
end
