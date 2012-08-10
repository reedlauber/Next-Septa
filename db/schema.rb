# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120809214854) do

  create_table "route_directions", :force => true do |t|
    t.string   "route_id"
    t.string   "route_short_name"
    t.integer  "direction_id"
    t.string   "direction_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "direction_long_name"
  end

  add_index "route_directions", ["route_id"], :name => "index_route_directions_on_route_id"
  add_index "route_directions", ["route_short_name"], :name => "index_route_directions_on_route_short_name"

  create_table "routes", :force => true do |t|
    t.string   "route_id"
    t.string   "route_short_name"
    t.string   "route_long_name"
    t.string   "route_desc"
    t.string   "agency_id"
    t.integer  "route_type"
    t.string   "route_color",      :limit => 6
    t.string   "route_text_color", :limit => 6
    t.string   "route_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "routes", ["route_id"], :name => "index_routes_on_route_id"

  create_table "shapes", :force => true do |t|
    t.integer  "shape_id"
    t.decimal  "shape_pt_lat"
    t.decimal  "shape_pt_lon"
    t.integer  "shape_pt_sequence"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shapes", ["shape_id"], :name => "index_shapes_on_shape_id"

  create_table "simplified_stops", :force => true do |t|
    t.string   "route_id"
    t.integer  "route_direction_id"
    t.integer  "direction_id"
    t.integer  "stop_id"
    t.string   "stop_name"
    t.integer  "stop_sequence"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "stop_lat"
    t.decimal  "stop_lon"
  end

  add_index "simplified_stops", ["route_direction_id"], :name => "index_simplified_stops_on_route_direction_id"
  add_index "simplified_stops", ["stop_id"], :name => "index_simplified_stops_on_stop_id"

  create_table "simplified_trips", :force => true do |t|
    t.string   "trip_name"
    t.integer  "route_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "simplified_trips", ["route_id"], :name => "index_simplified_trips_on_route_id"

  create_table "ss_test", :id => false, :force => true do |t|
    t.integer "stop_id"
    t.string  "stop_name"
    t.integer "stop_sequence"
  end

  create_table "stop_times", :force => true do |t|
    t.string   "trip_id"
    t.string   "arrival_time"
    t.string   "departure_time"
    t.integer  "stop_id"
    t.integer  "stop_sequence"
    t.integer  "pickup_type"
    t.integer  "drop_off_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stop_times", ["stop_id"], :name => "index_stop_times_on_stop_id"
  add_index "stop_times", ["trip_id"], :name => "index_stop_times_on_trip_id"

  create_table "stops", :force => true do |t|
    t.integer  "stop_id"
    t.string   "stop_name"
    t.decimal  "stop_lat"
    t.decimal  "stop_lon"
    t.string   "location_type"
    t.integer  "parent_station"
    t.integer  "zone_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stops", ["stop_id"], :name => "index_stops_on_stop_id"

  create_table "trip_variants", :force => true do |t|
    t.integer  "route_id"
    t.integer  "direction_id"
    t.string   "trip_headsign"
    t.integer  "stop_count"
    t.string   "variant_name"
    t.integer  "first_stop_sequence"
    t.integer  "last_stop_sequence"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "trips", :force => true do |t|
    t.string   "route_id"
    t.string   "service_id"
    t.string   "trip_id"
    t.string   "trip_headsign"
    t.integer  "block_id"
    t.integer  "direction_id"
    t.string   "trip_short_name"
    t.string   "shape_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "trip_variant_id"
  end

  add_index "trips", ["route_id"], :name => "index_trips_on_route_id"
  add_index "trips", ["trip_id"], :name => "index_trips_on_trip_id"

end
