module Pixeru
  module HAL
    module Display
      def self.init(width, height)
        PixeruDisplayHAL.init(width, height)
      end

      def self.send_buffer(buffer, width, height)
        PixeruDisplayHAL.send_buffer(buffer, width, height)
      end

      def self.shutdown
        PixeruDisplayHAL.shutdown
      end
    end
  end
end
