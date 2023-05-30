class ActivityController < ApplicationController
  def index
    @message = "ahoy from controller"
    
    results = Polyline.all.limit(2)
    

    @polylines = results.pluck(:summary).to_json.html_safe
  end

  def show
  end
end
