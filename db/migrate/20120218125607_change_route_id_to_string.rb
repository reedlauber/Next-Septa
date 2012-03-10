class ChangeRouteIdToString < ActiveRecord::Migration
  def self.up
  	say_with_time "Converting Routes" do
  		remove_index :routes, :route_id
		change_column :routes, :route_id, :string
		add_index :routes, :route_id
	end

	say_with_time "Converting Route Directions" do
		remove_index :route_directions, :route_id
  		change_column :route_directions, :route_id, :string
		add_index :route_directions, :route_id
  	end

  	say_with_time "Converting Simplified Stops" do
  		change_column :simplified_stops, :route_id, :string
  	end

	say_with_time "Converting Trips" do
		remove_index :trips, :route_id
  		change_column :trips, :route_id, :string
		add_index :trips, :route_id
  	end
  end

  def self.down
  	raise ActiveRecord::IrreversibleMigration, "Can't convert strings back into integers."
  end
end
