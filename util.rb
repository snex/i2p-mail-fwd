require 'date'

class Util
  MINUTES_PER_DAY = 1440.freeze

  def self.should_perform?(times_per_day)
    current_minute = Time.now.to_i - Time.new(Date.today.year, Date.today.month, Date.today.day).to_i / 60
    return true if rand(MINUTES_PER_DAY) % times_per_day == MINUTES_PER_DAY / times_per_day

    return false
  end
end
