class ActivityController < ApplicationController
  def index
    ending_date_range = 1.days.ago.end_of_day
    beginning_date_range = 600.days.ago.beginning_of_day

    results = Polyline.all.where(
      "activity_started_at_date_time BETWEEN ? AND ?", 
      beginning_date_range,
      ending_date_range)    

    @polylines = results.pluck(:summary).to_json.html_safe
  end

  def show
  end
end
