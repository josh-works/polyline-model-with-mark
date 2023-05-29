class ActivityController < ApplicationController
  def index
    @message = "ahoy from controller"
    @polylines = Polyline.all.pluck(:summary).to_json.html_safe
  end

  def show
  end
end
