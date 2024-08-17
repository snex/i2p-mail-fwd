require 'date'

class Util
  MINUTES_PER_DAY = 1440.freeze

  def self.should_perform?(times_per_day)
    rand < 1 - (MINUTES_PER_DAY - times_per_day) / MINUTES_PER_DAY.to_f
  end
end
