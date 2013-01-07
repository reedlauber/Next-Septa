class ChangeVariantRouteIdToString < ActiveRecord::Migration
  def self.up
  	change_column :trip_variants, :route_id, :string
  end

  def self.down
  end
end
