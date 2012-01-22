class AddLongNameToRouteDirection < ActiveRecord::Migration
  def self.up
  	add_column :route_directions, :direction_long_name, :string
  end

  def self.down
  	remove_column :route_directions, :direction_long_name
  end
end
