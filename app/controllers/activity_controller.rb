class ActivityController < ApplicationController
  def index
    @polylines = Polyline.all.pluck(:summary)
  end

  def show
  end
end
