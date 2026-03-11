module Pixeru
  module HAL
    module Audio
      def self.init(pin = nil)
        PixeruAudioHAL.init(pin || 0)
      end

      def self.tone(frequency_hz, duration_ms)
        PixeruAudioHAL.tone(frequency_hz, duration_ms)
      end

      def self.stop
        PixeruAudioHAL.stop
      end

      def self.shutdown
        PixeruAudioHAL.shutdown
      end
    end
  end
end
