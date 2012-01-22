class AddLatLonToSimplifiedStops < ActiveRecord::Migration
  def self.up
  	add_column :simplified_stops, :stop_lat, :decimal
  	add_column :simplified_stops, :stop_lon, :decimal
  end

  def self.down
  	remove_column :simplified_stops, :stop_lat
  	remove_column :simplified_stops, :stop_lon
  end
end
