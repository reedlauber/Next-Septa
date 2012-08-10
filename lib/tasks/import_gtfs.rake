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
  
  def import_batch(inst, columns, batch, batch_num, batch_start)
    start_time = Time.now
    puts "\nInserting batch #{batch_num} (starting at #{batch_start}) ..."
    import_fast(inst, columns, batch)
    time_spent = timer_interval(start_time, "Time spent inserting batch: ")
    time_spent
  end

  # helper to delete existing records, read CSV data into array of arrays, and import
  def import_type(paths, type, file_name, columns)
    puts "\n\n!!! Importing #{type}s !!!"
    
    inst = Object.const_get(type)
    
    batch_size = 50000
    batch_num = 0
    
    total_time = 0
    time_reading = 0
    time_writing = 0
    start_time = Time.now
    elapsed = 0
    
    puts "\nDeleting old values ..."
    ActiveRecord::Base.connection.execute("truncate table #{inst.table_name}")
    total_time += timer_interval(start_time, "Time spent deleting values: ")
    start_time = Time.now

    # loop over buses and/or rail files
    paths.each do |p|
      # collection holding all the data for the data type
      values = []

      # open and read data from CSV file
      CSV.foreach("#{p}/#{file_name}.txt", :headers => true) do |row|
        # data for individual row
        record_values = [] 
        # loop over headers and pull value for each column
        columns.each do |h| 
          if(row.field(h.to_s) != nil)
            record_values << row.field(h.to_s).strip
          else
            record_values << nil
          end
        end
        # add row data to total collection
        values << record_values
        
        if(values.count >= batch_size)
          batch_start = batch_num * batch_size
          batch_num += 1
          time_reading += timer_interval(start_time, "\nTime spent reading values: ")
          total_time += time_reading
          time_writing += import_batch(inst, columns, values, batch_num, batch_start)
          total_time += time_writing
          start_time = Time.now
          values = []
        end
      end
      
      if(values.count > 0)
        puts "\n#{values.count} to import ..."
        time_reading += timer_interval(start_time, "Time spent reading values: ")
        total_time += time_reading
        start_time = Time.now
        
        puts "\nInserting new values ..."
        import_fast(inst, columns, values)
        time_writing += timer_interval(start_time, "Time spenting inserting values: ")
        total_time += time_writing
      end
      
      puts "\nDone"
    end
    
    total_reading_formatted = format_time time_reading
    total_writing_formatted = format_time time_writing
    total_formatted = format_time total_time
    puts "Total time reading: #{total_reading_formatted}"
    puts "Total time writing: #{total_writing_formatted}"
    puts "Total time spent: #{total_formatted}"
  end

  # SHAPES
  if(args.type == "all" || args.type == "shapes")
    import_type(paths, "Shape", "shapes", [:shape_id, :shape_pt_lat, :shape_pt_lon, :shape_pt_sequence])
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
    ActiveRecord::Base.connection.execute("truncate table route_directions")
    total_time += timer_interval(start_time, "Time spent deleting values: ")
    start_time = Time.now
    
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
    ActiveRecord::Base.connection.execute("truncate table simplified_stops")
    total_time += timer_interval(start_time, "Time spent deleting values: ")
    start_time = Time.now
    
    puts "\nCreating new values ..."
    SimplifiedStop.generate_stops
    total_time += timer_interval(start_time, "Time spent creating values: ")
    
    total_formatted = format_time total_time
    puts "\nDone"
    puts "Total time spend: #{total_formatted}"
  end

  # TRIP VARIANTS
  if(args.type == "all" || args.type == "variants")
    puts "\n\n!!! Generating Trip Variants !!!"

    total_time = 0
    start_time = Time.now

    puts "\nDeleting old values ..."
    ActiveRecord::Base.connection.execute("truncate table trip_variants")
    total_time += timer_interval(start_time, "Time spent deleting values: ")
    start_time = Time.now

    puts "\nCreating new values ..."
    TripVariant.generate_variants
    total_time += timer_interval(start_time, "Time spent creating values: ")
    
    total_formatted = format_time total_time
    puts "\nDone"
    puts "Total time spend: #{total_formatted}"
  end
end