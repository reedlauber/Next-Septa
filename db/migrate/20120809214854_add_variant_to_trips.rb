class AddVariantToTrips < ActiveRecord::Migration
  def self.up
  	add_column :trips, :trip_variant_id, :integer
  end

  def self.down
  	remove_column :trips, :trip_variant_id
  end
end
