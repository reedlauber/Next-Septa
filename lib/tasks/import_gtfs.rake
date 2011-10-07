desc "Import GTFS data"
require "csv"
task :import_gtfs, [:type, :mode] => :environment do |t, args|
  args.with_defaults(:type => "all", :mode => "bus")
  
  puts "Starting import for: \"#{args.type}\""
  
  def import_helper(row, obj, type, label_index, label_index_sec)
    puts "Importing #{type}: " + row.field(label_index)# + (row.field(label_index_sec) if label_index_sec != nil)
    row.headers.each do |h|
      if(row.field(h) != nil)
        obj[h.lstrip] = row.field(h).lstrip
      end
    end
    obj.save
  end
  
  def import_route(row)
    route = Route.new
    import_helper(row, route, 'route', 1, nil)
    route.add_directions!
  end
  
  def import_stop(row)    
    stop = Stop.new
    import_helper(row, stop, 'stop', 1, nil)
  end
  
  def import_trip(row)
    trip = Trip.new
    import_helper(row, trip, 'trip', 3, nil)
  end
  
  def import_stoptime(row)
    stoptime = StopTime.new
    import_helper(row, stoptime, 'stop-time', 0, 4)
  end
  
  paths = []
  if(args.mode == "bus" || args.mode == "all")
    paths.push "db/gtfs/google_bus"
  end
  if(args.mode == "rail" || args.mode == "all")
    paths.push "db/gtfs/google_rail"
  end
  
  # STOPS
  if(args.type == "all" || args.type == "stops")
    puts ""
    puts "Importing Stops ..."
    Stop.destroy_all
    
    paths.each do |p|
      CSV.foreach("#{p}/stops.txt", :headers => true) do |row|
        import_stop(row)
      end
    end
  end
  
  # TRIPS
  if(args.type == "all" || args.type == "trips")
    puts ""
    puts "Importing Trips ..."
    Trip.destroy_all
    
    paths.each do |p|
      CSV.foreach("#{p}/trips.txt", :headers => true) do |row|
        import_trip(row)
      end
    end
  end
  
  # STOP TIMES
  if(args.type == "all" || args.type == "times")
    puts ""
    puts "Importing Stop Times ..."
    StopTime.destroy_all
    
    paths.each do |p|
      CSV.foreach("#{p}/stop_times.txt", :headers => true) do |row|
        import_stoptime(row)
      end
    end
  end

  # ROUTES
  if(args.type == "all" || args.type == "routes")
    puts ""
    puts "Importing Routes ..."
    RouteDirection.destroy_all
    Route.destroy_all

    paths.each do |p|
      CSV.foreach("#{p}/routes.txt", :headers => true) do |row|
        import_route(row)
      end
    end
  end
  
  # SIMPLIFIED STOPS
  if(args.type == "all" || args.type == "simplifiedstops")
    puts ""
    puts "Generating Simplified Stops ..."
    SimplifiedStop.generate_stops
  end
end