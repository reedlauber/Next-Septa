class StopTime < ActiveRecord::Base
  def convert!(to_stop)
    d_time = self.departure_time
    d_time_parts = d_time.split(':')
    if(d_time_parts[0].to_i > 23)
      d_time = "0" + (d_time_parts[0].to_i - 24).to_s + ":" + d_time_parts[1] + ":00"
    end

    depart_time = Time.zone.parse(d_time)
    now = Time.zone.now

    from_now = time_period_to_s depart_time - now

    if(to_stop != nil)
      to_stop_time = StopTime.where("trip_id = '#{self.trip_id}' AND stop_id = #{to_stop.stop_id}").first
      if(to_stop_time != nil)
        a_time = to_stop_time.departure_time
        a_time_parts = a_time.split(':')
        if(a_time_parts[0].to_i > 23)
          a_time = "0" + (a_time_parts[0].to_i - 24).to_s + ":" + a_time_parts[1] + ":00"
        end

        arrive_time = Time.parse(a_time)
      else
        logger.warn "Couldn't find TO stop_time for trip_id: '#{self.trip_id}' and stop_id: #{to_stop.stop_id}."
      end
    end

    {
      "departure_time" => depart_time,
      "arrival_time" => arrive_time,
      "from_now" => from_now,
      "departure_stop_time" => self,
      "arrival_stop_time" => to_stop_time,
      "trip_id" => self.trip_id,
      "block_id" => self.block_id
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

    interval_array = [[:weeks, 604800], [:days, 86400], [:hrs, 3600], [:mins, 60]]
    if(time_period < 0)
        time_str = 'GONE'
    elsif(time_period < 60)
        time_str = '< 1 min'
    else
      interval_array.each do |sub|
        if time_period >= sub[1] then
          time_val, time_period = time_period.divmod(sub[1])

          time_val == 1 ? name = sub[0].to_s.singularize : name = sub[0].to_s

          (sub[0] != :mins ? time_str += ", " : time_str += " ") if time_str != ''
          time_str += time_val.to_s + " #{name}"
        end
      end
    end

    time_str
  end
end
