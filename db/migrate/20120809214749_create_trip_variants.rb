class CreateTripVariants < ActiveRecord::Migration
  def self.up
    create_table :trip_variants do |t|
      t.integer :route_id
      t.integer :direction_id
      t.string :trip_headsign
      t.integer :stop_count
      t.string :variant_name
      t.integer :first_stop_sequence
      t.integer :last_stop_sequence

      t.timestamps
    end
  end

  def self.down
    drop_table :trip_variants
  end
end
