class CreatePolyline < ActiveRecord::Migration[7.0]
  def change
    create_table :polylines do |t|
      t.string :activity_name
      t.string :summary
      t.string :detail
      


      t.timestamps
    end
  end
end

# Activity.