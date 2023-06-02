class ChangeIntegerLimitInPolylines < ActiveRecord::Migration[7.0]
  def change
    change_column :polylines, :activity_id, :integer, limit: 8

  end
end
