class AddStopNameToSimplifiedStop < ActiveRecord::Migration
  def self.up
    add_column :simplified_stops, :direction_id, :integer
    add_column :simplified_stops, :stop_name, :string
  end

  def self.down
    remove_column :simplified_stops, :stop_name
    remove_column :simplified_stops, :direction_id
  end
end
