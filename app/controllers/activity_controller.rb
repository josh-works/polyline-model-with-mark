class ActivityController < ApplicationController
  def index
    @message = "ahoy from controller"
    @polylines = Polyline.all.pluck(:summary)
  end

  def show
  end
end
