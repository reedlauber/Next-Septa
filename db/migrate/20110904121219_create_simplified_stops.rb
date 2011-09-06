class CreateSimplifiedStops < ActiveRecord::Migration
  def self.up
    create_table :simplified_stops do |t|
      t.integer "route_id"
      t.integer "route_direction_id"
      t.integer "stop_id"
      t.integer "stop_sequence"
      t.timestamps
    end
    add_index :simplified_stops, :route_direction_id
    add_index :simplified_stops, :stop_id
  end

  def self.down
    drop_table :simplified_stops
  end
end
