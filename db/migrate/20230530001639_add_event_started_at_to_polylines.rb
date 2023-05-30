class AddEventStartedAtToPolylines < ActiveRecord::Migration[7.0]
  def change
    add_column :polylines, :started_at, :date
  end
end
