class Screen::ReportList < Screen::Basic

  attr_accessor :report_ids,:erase_all_url

  url screen: 'report' 


  def clear_all
  	parse(self.client.get(self.erase_all_url)) if (!self.erase_all_url.nil?)
  end

end