desc "Import GTFS data"
require "csv"
task :import_gtfs, [:type, :mode] => :environment do |t, args|
  args.with_defaults(:type => "all", :mode => "bus")
  
  puts "Starting import for: \"#{args.type}\""
  
  def import_route(row)
    puts "Importing route: " + row.field(1)
    route = Route.new
    row.headers.each do |h|
      if(row.field(h) != nil)
        route[h.lstrip] = row.field(h).lstrip
      end
    end
    route.save
    route.add_directions!
  end
  
  def import_stop(row)
    puts "Importing stop: " + row.field(1)
    stop = Stop.new
    row.headers.each do |h|
      if(row.field(h) != nil)
        stop[h.lstrip] = row.field(h).lstrip
      end
    end
    stop.save
  end
  
  def import_trip(row)
    puts "Importing trip: " + row.field(2)
    trip = Trip.new
    row.headers.each do |h|
      if(row.field(h) != nil)
        trip[h.lstrip] = row.field(h).lstrip
      end
    end
    trip.save
  end
  
  def import_stoptime(row)
    puts "Importing stop-time: " + row.field(0) + "-" + row.field(4)
    stoptime = StopTime.new
    row.headers.each do |h|
      if(row.field(h) != nil)
        stoptime[h.lstrip] = row.field(h).lstrip
      end
    end
    stoptime.save
  end
  
  paths = []
  if(mode == "bus" || mode == "all") paths.push("db/gtfs/google_bus") end
  if(mode == "rail" || mode == "all") paths.push("db/gtfs/google_rail") end
  
  if(args.type == "all" || args.type == "routes")
    RouteDirection.destroy_all
    Route.destroy_all
    
    paths.each do |p|
      CSV.foreach('#{p}/routes.txt', :headers => true) do |row|
        import_route(row)
      end
    end
  end
  
  if(args.type == "all" || args.type == "stops")
    Stop.destroy_all
    
    paths.each do |p|
      CSV.foreach('#{p}/stops.txt', :headers => true) do |row|
        import_stop(row)
      end
    end
  end
  
  if(args.type == "all" || args.type == "trips")
    Trip.destroy_all
    
    paths.each do |p|
      CSV.foreach('#{p}/trips.txt', :headers => true) do |row|
        import_trip(row)
      end
    end
  end
  
  if(args.type == "all" || args.type == "times")
    StopTime.destroy_all
    
    paths.each do |p|
      CSV.foreach('#{p}/stop_times.txt', :headers => true) do |row|
        import_stoptime(row)
      end
    end
  end
  
  if(args.type == "all" || args.type == "simplifiedstops")
    SimplifiedStop.generate_stops
  end
end