class ImportTimer
	def initialize
		@start = Time.now
		@old = 0
	end

	def start
		@start = Time.now
	end

	def stop
		@old += (Time.now - @start) * 1
	end

	def total(message, stop_first = true)
		if stop_first
			stop
		end
		formatted = format_time(@old)
		puts message + ": " + formatted
	end

	def interval(message, stop_timer = false)
		elapsed = (Time.now - @start) * 1
		formatted = format_time(elapsed)
		puts message + ": " + formatted
		if stop_timer
			stop
		end
	end

	private

	def format_time(secs)
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
end