class CreateShapes < ActiveRecord::Migration
  def self.up
    create_table :shapes do |t|
      t.integer "shape_id" #shape_id,shape_pt_lat,shape_pt_lon,shape_pt_sequence
      t.decimal "shape_pt_lat"
      t.decimal "shape_pt_lon"
      t.integer "shape_pt_sequence"
      t.timestamps
    end

    add_index :shapes, :shape_id
  end

  def self.down
    drop_table :shapes
  end
end
