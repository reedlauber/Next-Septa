class CreateTrips < ActiveRecord::Migration
  def self.up
    create_table :trips do |t|
      t.integer "route_id"
      t.string "service_id"
      t.string "trip_id"
      t.string "trip_headsign"
      t.integer "block_id"
      t.string "trip_short_name"
      t.string "shape_id"
      t.timestamps
    end
    add_index :trips, :route_id
    add_index :trips, :trip_id
  end

  def self.down
    drop_table :trips
  end
end
