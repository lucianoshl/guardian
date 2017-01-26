class Screen::ReportView < Screen::Basic

  attr_accessor :report

  url screen: 'report', mode: 'attack'

  def self.load_all
    Rails.logger.debug("Loading all reports: start")
    
    while !(page = Screen::ReportList.new(mode: 'attack')).report_ids.empty? do
      page.report_ids.map do |report_id|
        report_screen = Screen::ReportView.new(view: report_id)
        raise "Error reading report=#{report_id} Errors = #{report_screen.report.errors.inspect}" if (!report_screen.report.save)

        # if (!report_screen.report.loyalty_destroyed.nil?)
        # end

        report_screen.report.erase(report_screen)
      end
      
    end

    Rails.logger.debug("Loading all reports: end")
  end

end
