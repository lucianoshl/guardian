class Screen::ReportView < Screen::Logged

  attr_accessor :report

  url screen: 'report', mode: 'all'

  def self.load_all
    
    while !(page = Screen::ReportList.new(mode: 'attack')).report_ids.empty? do
      page.report_ids.map do |report_id|
        report_screen = Screen::ReportView.new(view: report_id)
        raise "Error reading report=#{report_id} Errors = #{report_screen.report.errors.inspect}" if (!report_screen.report.save)
        report_screen.report.erase(report_screen)
      end
      
    end
  end

end