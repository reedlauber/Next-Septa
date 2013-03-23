class StopTime < ActiveRecord::Base
  def self.parse_time(time_str)
    d_time_parts = time_str.split(':')
    if(d_time_parts[0].to_i > 23)
      time_str = "0" + (d_time_parts[0].to_i - 24).to_s + ":" + d_time_parts[1] + ":00"
    end

    Time.parse(time_str)
  end

  def convert(to_stop)
    d_time = self.departure_time.strip
    d_time_parts = d_time.split(':')
    depart_time = 0
    time_diff = 0

    if(d_time_parts[0].to_i > 23)
      d_time = "0" + (d_time_parts[0].to_i - 24).to_s + ":" + d_time_parts[1] + ":00"
      depart_time = Time.parse(d_time)
      time_diff = (depart_time + (60 * 60 * 24)) - Time.now
    else
      depart_time = Time.parse(d_time)
      time_diff = depart_time - Time.now
    end

    from_now = time_period_to_s(time_diff)

    if(to_stop != nil)
      to_stop_time = StopTime.where("trip_id = ? AND stop_id = ?", self.trip_id, to_stop.stop_id).first
      if(to_stop_time != nil)
        a_time = to_stop_time.departure_time.strip
        a_time_parts = a_time.split(':')
        if(a_time_parts[0].to_i > 23)
          a_time = "0" + (a_time_parts[0].to_i - 24).to_s + ":" + a_time_parts[1] + ":00"
        end

        arrive_time = Time.parse(a_time)
      else
        logger.warn "Couldn't find TO stop_time for trip_id: '#{self.trip_id}' and stop_id: #{to_stop.stop_id}."
      end
    end

    arrive_time_formatted = arrive_time == nil ? nil : arrive_time.to_formatted_s(:display_time)
    coverage_left = ((self.first_stop_sequence.to_i - 1) / self.stop_count.to_f) * 100
    coverage_left = 0 if coverage_left < 0
    coverage_right = (1 - (self.last_stop_sequence.to_i / self.stop_count.to_f)) * 100
    coverage_right = 0 if coverage_right < 0

    {
      "departure_time" => depart_time,
      "arrival_time" => arrive_time,
      "departure_time_formatted" => depart_time.to_formatted_s(:display_time),
      "arrival_time_formatted" => arrive_time_formatted,
      "from_now" => from_now,
      "departure_stop_time" => self,
      "arrival_stop_time" => to_stop_time,
      "trip_id" => self.trip_id,
      "block_id" => self.block_id,
      "coverage_left" => coverage_left,
      "coverage_right" => coverage_right
    }
  end

  def self.convert_list(stop_times, to_stop)
    converted = []
    stop_times.each do |stop_time|
      converted.push stop_time.convert(to_stop)
    end
    converted
  end

  def time_period_to_s(time_period)
    time_str = ''

    interval_array = [[:weeks, 604800], [:days, 86400], [:hrs, 3600], [:mins, 60]]
    if(time_period < 0)
        time_str = 'GONE'
    elsif(time_period < 60)
        time_str = '< 1m'
    else
      interval_array.each do |sub|
        if time_period >= sub[1] then
          time_val, time_period = time_period.divmod(sub[1])

          name = sub[0].to_s[0]

          time_str += " " if !time_str.empty?
          time_str += time_val.to_s + "#{name}"
        end
      end
    end

    time_str
  end
end