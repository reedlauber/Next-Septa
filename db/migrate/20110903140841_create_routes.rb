class CreateRoutes < ActiveRecord::Migration
  def self.up
    create_table :routes do |t|
      t.integer "route_id"
      t.string "route_short_name"
      t.string "route_long_name"
      t.string "route_desc"
      t.string "agency_id"
      t.integer "route_type"
      t.string "route_color", :limit => 6
      t.string "route_text_color", :limit => 6
      t.string "route_url"
      t.timestamps
    end
    add_index :routes, :route_id
  end

  def self.down
    drop_table :routes
  end
end
