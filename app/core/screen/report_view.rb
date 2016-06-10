class Screen::ReportView < Screen::Logged

  attr_accessor :report

  url screen: 'report', mode: 'all'

end