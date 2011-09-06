class CreateRouteDirections < ActiveRecord::Migration
  def self.up
    create_table :route_directions do |t|
      t.integer "route_id"
      t.string "route_short_name"
      t.integer "direction_id"
      t.string "direction_name"
      t.timestamps
    end
    add_index :route_directions, :route_id
    add_index :route_directions, :route_short_name
  end

  def self.down
    drop_table :route_directions
  end
end
