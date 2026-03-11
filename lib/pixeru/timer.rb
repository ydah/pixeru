module Pixeru
  START_TIME = Time.now

  def self.tick_count
    ((Time.now - START_TIME) * 1000).to_i
  end

  class Timer
    def initialize
      @start_time = Time.now
    end

    def start
      @start_time = Time.now
    end

    def reset
      start
    end

    def elapsed_ms
      ((Time.now - @start_time) * 1000).to_i
    end

    def elapsed_s
      Time.now - @start_time
    end

    # Periodic event helper
    # Returns true every interval_ms milliseconds
    def every(interval_ms)
      if elapsed_ms >= interval_ms
        reset
        yield if block_given?
        return true
      end
      false
    end
  end
end
