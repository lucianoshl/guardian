class Mobile::ReportList < Mobile::Base

	entry :reports_get_reports
	attr_accessor :reports

	def parse page
		self.reports = page["result"].map{|a|a[0].to_i}
	end 

	def self.erase report_id
		client = Mobile::Client.new
		result = client.post("https://#{User.current.world}.tribalwars.com.br/m/g/reports_delete",[client.sid,report_id])
	end

	def self.load_all
		Rails.logger.info("Loading all reports: start")

		loop do
			report_list = Mobile::ReportList.new('attack',0,0,2000).reports
			Rails.logger.info("Loading all reports: request with #{report_list.size} reports")
			report_list.pmap do |report_id|
				report_screen = Mobile::ReportView.new(view: report_id)

				raise Exception.new("Relatorio com problema #{report_id} #{report_screen.report.occurrence}") if (report_screen.report.occurrence > Time.zone.now)

				saved = Report.where(rid: report_id).count > 0

				raise "Error reading report=#{report_id} Errors = #{report_screen.report.errors.inspect}" if (!saved && !report_screen.report.save)

				my_attack_troops = Troop.new(report_screen.report.origin_troops)
				my_looses = Troop.new(report_screen.report.origin_troops_losses)
				target_troops = Troop.new(report_screen.report.target_troops)

				not_erase = my_attack_troops.snob > 0 || my_attack_troops.population >= 5000 || my_attack_troops.spy > 50 || target_troops.total > 0
				my_looses.population > 500 || my_attack_troops.population == my_looses.population

				erase(report_id) if !not_erase
			end	
			
			break if (report_list.size < 55)
		end
		Rails.logger.info("Loading all reports: end")
	end

end