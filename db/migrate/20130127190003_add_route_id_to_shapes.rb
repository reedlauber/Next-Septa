class AddRouteIdToShapes < ActiveRecord::Migration
  def self.up
  	add_column :shapes, :route_id, :string
  end

  def self.down
  	remove_column :shapes, :route_id
  end
end
