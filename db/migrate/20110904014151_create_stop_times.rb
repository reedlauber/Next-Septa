class CreateStopTimes < ActiveRecord::Migration
  def self.up
    create_table :stop_times do |t|
      t.string "trip_id"
      t.string "arrival_time"
      t.string "departure_time"
      t.integer "stop_id"
      t.integer "stop_sequence"
      t.integer "pickup_type"
      t.integer "drop_off_type"
      t.timestamps
    end
    add_index :stop_times, :trip_id
    add_index :stop_times, :stop_id
  end

  def self.down
    drop_table :stop_times
  end
end
