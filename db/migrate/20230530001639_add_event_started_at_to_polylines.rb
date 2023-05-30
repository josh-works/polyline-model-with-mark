class AddEventStartedAtToPolylines < ActiveRecord::Migration[7.0]
  def change
    add_column :polylines, :activity_started_at_date_time, :datetime
  end
end
