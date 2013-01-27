class Importer
	@@batch_size = 30000
	@@gtfs_path = "db/gtfs"

	def initialize(mode = "all", type = "all")
		@mode = mode
		@type = type
		@paths = []
		if(mode == "bus" || mode == "all")
			@paths.push "#{@@gtfs_path}/google_bus"
		end
		if(mode == "rail" || mode == "all")
			@paths.push "#{@@gtfs_path}/google_rail"
		end
	end

	def import_type(type, file_name, columns)
		puts "\n\n!!! Importing #{type}s !!!"

		inst = Object.const_get(type)

		total_timer = ImportTimer.new

		delete_values(inst.table_name, total_timer)
		total_timer.start

		read_timer = ImportTimer.new
		write_timer = ImportTimer.new

		# loop over buses and/or rail files
		@paths.each do |p|
			import_path(p, file_name, inst, columns, read_timer, write_timer)
		end

		puts "\nDone"
		read_timer.total("Total time reading", true)
		write_timer.total("Total time writing", true)
		total_timer.total("Total time spent")
	end

	def import_route_extras
		import_extra("Generating Route Directions", "route_directions") do
			RouteDirection.generate_directions
		end
	end

	def import_route_shapes
		import_extra("Generating Route Shapes") do
			Route.assign_route_shapes
		end
	end

	def import_simplified_stops
		import_extra("Generating Simplified Stops", "simplified_stops") do
			SimplifiedStop.generate_stops
		end
	end

	def import_trip_variants
		import_extra("Generating Trip Variants", "trip_variants") do
			TripVariant.generate_variants
		end
	end

	def import_shapes?
		@type == "all" || @type == "shapes"
	end

	def import_stops?
		@type == "all" || @type == "stops"
	end

	def import_trips?
		@type == "all" || @type == "trips"
	end

	def import_times?
		@type == "all" || @type == "times"
	end

	def import_routes?
		@type == "all" || @type == "routes"
	end

	def import_route_shapes?
		@type == "all" || @type == "routeshapes"
	end

	def import_simplifiedstops?
		@type == "all" || @type == "simplifiedstops"
	end

	def import_variants?
		@type == "all" || @type == "variants"
	end

	private

	def delete_values(table_name, timer)
		puts "\nDeleting old values ..."
		ActiveRecord::Base.connection.execute("truncate table #{table_name}")
		timer.interval("Time spent deleting values", true)
	end

  	# helper to import using activerecord-import gem
	def import_fast(inst, columns, values)
		inst.import columns, values
  	end

	def import_batch(inst, columns, batch, batch_num, batch_start)
		puts "\nInserting batch #{batch_num} (starting at #{batch_start}) ..."
		import_fast(inst, columns, batch)
	end

	# helper function for non-file-based "extras" imports
	def import_extra(title, table=nil)
		puts "\n\n!!! #{title} !!!"
		timer = ImportTimer.new

		if(table != nil)
			delete_values(table, timer)
		end

		puts "\nCreating new values ..."
		yield
		timer.interval("Time spent creating values")

		puts "\nDone"
		timer.total("Total time spent")
	end

	# builds a reference hash to normalize CSV header columns with spaces to the expected trimmed versions
	def get_clean_headers(original, columns)
		cleaned = Hash.new
		original.each do |h|
			if columns.include? h.strip
				cleaned[h.strip] = h
			end
		end
		cleaned
	end

	# for a given path (rail vs buses), read in mode file and process rows
	def import_path(path, file_name, inst, columns, read_timer, write_timer)
		# collection holding all the data for the data type
		values = []
		batch_num = 0
		clean_headers = nil

		# open and read data from CSV file
		CSV.foreach("#{path}/#{file_name}.txt", :headers => true) do |row|
			read_timer.start

			if(clean_headers == nil)
				clean_headers = get_clean_headers(row.headers, columns)
			end

			# data for individual row
			record_values = []
			# loop over headers and pull value for each column
			columns.each do |c|
				key = clean_headers[c]
				val = nil

				if(key != nil)
					val = row.field(key)
					if(val != nil)
						val.strip!
					end
				end

				record_values << val
			end
			# add row data to total collection
			values << record_values

			if(values.count >= @@batch_size)
				batch_start = batch_num * @@batch_size
				batch_num += 1
				read_timer.interval("\nTime spent reading values", true)

				write_timer.start
				import_batch(inst, columns, values, batch_num, batch_start)
				write_timer.interval("Time spent inserting batch", true)

				values = []
			end
		end

		if(values.count > 0)
			puts "\n#{values.count} to import ..."
			read_timer.interval("Time spent reading values", true)

			puts "\nInserting new values ..."
			write_timer.start
			import_fast(inst, columns, values)
			write_timer.interval("Time spent inserting batch", true)
		end
	end
end