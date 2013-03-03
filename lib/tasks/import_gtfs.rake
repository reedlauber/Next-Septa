desc "Import GTFS data"
require "csv"
require "import_timer.rb"
require "importer.rb"

task :import_gtfs, [:type, :mode] => :environment do |t, args|
	args.with_defaults(:type => "all", :mode => "all")

	puts "Starting import for: \"#{args.type}\", mode: \"#{args.mode}\""

	importer = Importer.new(args.mode, args.type)

	timer = ImportTimer.new

	# SHAPES
	if importer.import_shapes?
		importer.import_type("Shape", "shapes", ['shape_id', 'shape_pt_lat', 'shape_pt_lon', 'shape_pt_sequence'])
	end

	# STOPS
	if importer.import_stops?
		importer.import_type("Stop", "stops", ['stop_id', 'stop_name', 'stop_lat', 'stop_lon', 'location_type', 'parent_station', 'zone_id'])
	end

	# TRIPS
	if importer.import_trips?
		importer.import_type("Trip", "trips", ['route_id', 'service_id', 'trip_id', 'trip_headsign', 'block_id', 'direction_id', 'trip_short_name', 'shape_id'])
	end

	# STOP TIMES
	if importer.import_times?
		importer.import_type("StopTime", "stop_times", ['trip_id', 'arrival_time', 'departure_time', 'stop_id', 'stop_sequence'])
	end

	# ROUTES
	if importer.import_routes?
		importer.import_type("Route", "routes", ['route_id', 'route_short_name', 'route_long_name', 'route_type', 'route_color', 'route_text_color', 'route_url'])
		importer.import_route_extras
	end

	# ROUTE SHAPES
	if importer.import_route_shapes?
		importer.import_route_shapes
	end

	# SIMPLIFIED STOPS
	if(args.type == "all" || args.type == "simplifiedstops")
		importer.import_simplified_stops
	end

	# TRIP VARIANTS
	if(args.type == "all" || args.type == "variants")
		importer.import_trip_variants
	end

	puts "\n\n>>> Import Complete <<<"
	timer.total("Total import time")
end