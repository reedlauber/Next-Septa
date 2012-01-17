desc "Import GTFS data"
require "csv"
task :import_gtfs, [:type, :mode] => :environment do |t, args|
  args.with_defaults(:type => "all", :mode => "bus")
  
  puts "Starting import for: \"#{args.type}\", mode: \"#{args.mode}\""
  
  # decide with paths to bus and/or rail data to include
  paths = []
  if(args.mode == "bus" || args.mode == "all")
    paths.push "db/gtfs/google_bus"
  end
  if(args.mode == "rail" || args.mode == "all")
    paths.push "db/gtfs/google_rail"
  end
  
  def format_time secs
    hrs = 0
    mins = 0
    
    if(secs > 59)
      mins = (secs / 60).to_i
      secs = secs - (mins * 60).to_i
      secs = secs.to_i
    end
    
    if(mins > 59)
      hrs = (mins / 60).to_i
      mins = mins - (hrs * 60).to_i
    end
    
    time = ""
    if(hrs > 0)
      time = hrs.to_s + " hours "
    end
    if(mins > 0)
      time += mins.to_s + " minutes "
    end
    time += secs.to_s + " seconds"
    time
  end
  
  def timer_interval(start_time, message)
    elapsed = (Time.now - start_time) * 1
    formatted = format_time elapsed
    puts message + formatted
    elapsed
  end

  # helper to import using activerecord-import gem
  def import_fast(inst, columns, values)
    inst.import columns, values
  end

  # helper to delete existing records, read CSV data into array of arrays, and import
  def import_type(paths, type, file_name, columns)
    puts "\n\n!!! Importing #{type}s !!!"
    
    inst = Object.const_get(type)
    
    batch_size = 50000
    
    total_time = 0
    start_time = Time.now
    elapsed = 0

    # loop over buses and/or rail files
    paths.each do |p|
      # collection holding all the data for the data type
      values = []

      # open and read data from CSV file
      CSV.foreach("#{p}/#{file_name}.txt", :headers => true) do |row|
        # data for individual row
        record_values = [] 
        # loop over headers and pull value for each column
        row.headers.each do |h| 
          if(row.field(h) != nil)
            record_values << row.field(h).strip
          else
            record_values << nil
          end
        end
        # add row data to total collection
        values << record_values
      end
      
      puts "\n#{values.count} to import ..."
      total_time += timer_interval(start_time, "Time spent reading values: ")
      start_time = Time.now

      puts "\nDeleting old values ..."
      ActiveRecord::Base.connection.execute("truncate table #{inst.table_name}")
      #inst.destroy_all
      total_time += timer_interval(start_time, "Time spent deleting values: ")
      start_time = Time.now
      
      if(values.count > batch_size)
        batched_values = []
        batch_num = 0
        values.each do |v|
          batched_values << v
          if(batched_values.count == batch_size)
            batch_start = batch_num * batch_size
            batch_num += 1
            puts "\nInserting batch #{batch_num} (#{batch_start} of #{values.count}) ..."
            import_fast(inst, columns, batched_values)
            batched_values = []
            total_time += timer_interval(start_time, "Time spent inserting batch: ")
            start_time = Time.now
          end
        end
        
        if(batched_values.count > 0)
          puts "\nInserting batch of #{batched_values.count} values ..."
          import_fast(inst, columns, batched_values)
          total_time += timer_interval(start_time, "Time spent inserting batch: ")
        end
      else
        puts "\nInserting new values ..."
        import_fast(inst, columns, values)
        total_time += timer_interval(start_time, "Time spent inserting values: ")
      end
      
      puts "\nDone"
    end
    
    total_formatted = format_time total_time
    puts "Total time spent: #{total_formatted}"
  end
  
  # STOPS
  if(args.type == "all" || args.type == "stops")
    import_type(paths, "Stop", "stops", [:stop_id, :stop_name, :stop_lat, :stop_lon, :location_type, :parent_station, :zone_id])
  end
  
  # TRIPS
  if(args.type == "all" || args.type == "trips")
    import_type(paths, "Trip", "trips", [:route_id, :service_id, :trip_id, :trip_headsign, :block_id, :direction_id, :shape_id])
  end
  
  # STOP TIMES
  if(args.type == "all" || args.type == "times")
    import_type(paths, "StopTime", "stop_times", [:trip_id, :arrival_time, :departure_time, :stop_id, :stop_sequence])
  end

  # ROUTES
  if(args.type == "all" || args.type == "routes")
    import_type(paths, "Route", "routes", [:route_id, :route_short_name, :route_long_name, :route_type, :route_url])

    puts "\n\n!!! Generating Route Directions !!!"
    total_time = 0
    start_time = Time.now
    
    puts "\nDeleting old values ..."
    RouteDirection.destroy_all
    total_time += timer_interval(start_time, "Time spent deleting values: ")
    
    puts "\nCreating new values ..."
    RouteDirection.generate_directions
    total_time += timer_interval(start_time, "Time spent creating values: ")
    
    total_formatted = format_time total_time
    puts "\nDone"
    puts "Total time spend: #{total_formatted}"
  end
  
  # SIMPLIFIED STOPS
  if(args.type == "all" || args.type == "simplifiedstops")
    puts "\n\n!!! Generating Simplified Stops !!!"
    
    total_time = 0
    start_time = Time.now
    
    puts "\nDeleting old values ..."
    SimplifiedStop.destroy_all
    total_time += timer_interval(start_time, "Time spent deleting values: ")
    
    puts "\nCreating new values ..."
    SimplifiedStop.generate_stops
    total_time += timer_interval(start_time, "Time spent creating values: ")
    
    total_formatted = format_time total_time
    puts "\nDone"
    puts "Total time spend: #{total_formatted}"
  end
end