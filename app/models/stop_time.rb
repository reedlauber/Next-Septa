class StopTime < ActiveRecord::Base
  def convert!(to_stop)
    to_stop_time = StopTime.where("trip_id = '#{self.trip_id}' AND stop_id = #{to_stop.stop_id}").first
    
    d_time = self.departure_time
    a_time = to_stop_time.departure_time
  
    d_time_parts = d_time.split(':')
    if(d_time_parts[0].to_i > 23)
      d_time = "0" + (d_time_parts[0].to_i - 24).to_s + ":" + d_time_parts[1] + ":00"
    end
    
    a_time_parts = a_time.split(':')
    if(a_time_parts[0].to_i > 23)
      a_time = "0" + (a_time_parts[0].to_i - 24).to_s + ":" + a_time_parts[1] + ":00"
    end
    
    depart_time = Time.parse(d_time)
    arrive_time = Time.parse(a_time)
    from_now = time_period_to_s depart_time - Time.now
    
    { 
      "departure_time" => depart_time, 
      "arrival_time" => arrive_time, 
      "from_now" => from_now, 
      "departure_stop_time" => self,
      "arrival_stop_time" => to_stop_time
    }
  end
  
  def self.convert_list(stop_times, to_stop)
    converted = []
    stop_times.each do |stop_time|
      converted.push stop_time.convert!(to_stop)
    end
    converted
  end
  
  def time_period_to_s(time_period)
    time_str = ''

    interval_array = [[:weeks, 604800], [:days, 86400], [:hours, 3600], [:mins, 60]]
    interval_array.each do |sub|
      if time_period >= sub[1] then
        time_val, time_period = time_period.divmod(sub[1])

        time_val == 1 ? name = sub[0].to_s.singularize : name = sub[0].to_s

        (sub[0] != :mins ? time_str += ", " : time_str += " and ") if time_str != ''
        time_str += time_val.to_s + " #{name}"
      end
    end

    time_str 
  end
end