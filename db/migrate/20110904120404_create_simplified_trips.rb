class CreateSimplifiedTrips < ActiveRecord::Migration
  def self.up
    create_table :simplified_trips do |t|
      t.string "trip_name"
      t.integer "route_id"
      t.timestamps
    end
    add_index :simplified_trips, :route_id
  end

  def self.down
    drop_table :simplified_trips
  end
end
