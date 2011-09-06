class CreateStops < ActiveRecord::Migration
  def self.up
    create_table :stops do |t|
      t.integer "stop_id"
      t.string "stop_name"
      t.decimal "stop_lat"
      t.decimal "stop_lon"
      t.string "location_type"
      t.integer "parent_station"
      t.integer "zone_id"
      t.timestamps
    end
    add_index :stops, :stop_id
  end

  def self.down
    drop_table :stops
  end
end
