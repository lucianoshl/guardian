class ReportController < ApplicationController

  before_filter do 
    @criteria = Report
  end

  def index
    @report = @criteria.all
  end

  def show
    @report = @criteria.find(params["id"])
  end

  def read_all
    @criteria.update_all read: true
    redirect_to request.referer
  end
end
