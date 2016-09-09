class Mobile::ReportList < Mobile::Base

	entry :reports_get_reports
	attr_accessor :reports

	def parse page
		self.reports = page["result"].map{|a|a[0].to_i}
	end 

	def self.erase report_id
		result = Mobile::Client.new.post("https://#{User.current.world}.tribalwars.com.br/m/g/reports_delete",[$sid,report_id])
	end

	def self.load_all
		Rails.logger.debug("Loading all reports: start")
		report_list = Mobile::ReportList.new('attack',0,0,2000).reports
		report_list.map do |report_id|
			report_screen = Mobile::ReportView.new(id: report_id)
			raise "Error reading report=#{report_id} Errors = #{report_screen.report.errors.inspect}" if (!report_screen.report.save)
			erase(report_id)
		end
		Rails.logger.debug("Loading all reports: end")
	end

end