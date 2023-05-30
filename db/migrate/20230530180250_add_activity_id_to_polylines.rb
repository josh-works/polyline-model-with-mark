class AddActivityIdToPolylines < ActiveRecord::Migration[7.0]
  def change
    add_column :polylines, :activity_id, :integer
  end
end
