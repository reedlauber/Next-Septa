class AddRouteIdToSimplifiedStops < ActiveRecord::Migration
  def self.up
    add_column :simplified_stops, :route_id, :integer
  end

  def self.down
    remove_column :simplified_stops, :route_id
  end
end
