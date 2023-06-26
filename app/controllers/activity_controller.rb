class ActivityController < ApplicationController
  def index
    if activities_params["days"]
      days = activities_params["days"].to_i || 1
      ending_date_range = 1.days.ago.end_of_day
      beginning_date_range = days.days.ago

      results = Polyline.all.where(
        "activity_started_at_date_time BETWEEN ? AND ?", 
        beginning_date_range,
        ending_date_range
      )    
    end

    if activities_params["begin"]
      beginning_date = DateTime.parse(activities_params["begin"]).beginning_of_day
      ending_date = DateTime.parse(activities_params["end"]).end_of_day


      results = Polyline.all.where(
        "activity_started_at_date_time BETWEEN ? AND ?", 
        beginning_date,
        ending_date
      )    
    end

    if results.nil?
      results = Polyline.all
    end
    # results = Polyline.all


    if results
      @polylines = results.to_json.html_safe
    else
      @polylines = "".to_json.html_safe
    end
  end

  def show
    @polyline = Polyline.find(params[:id]).to_json.html_safe
  end

  private

    def activities_params
      params.permit(:days, :month, :begin, :end, :latlng, :zoom)
    end
end
