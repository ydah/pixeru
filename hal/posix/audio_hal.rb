module Pixeru
  module HAL
    module Audio
      def self.init(pin = nil)
      end

      def self.tone(frequency_hz, duration_ms)
        STDOUT.write "♪ tone: #{frequency_hz}Hz #{duration_ms}ms\n"
      end

      def self.stop
      end

      def self.shutdown
      end
    end
  end
end
