module Pixeru
  module HAL
    module Input
      @button_map = {}
      @registered_pins = {}
      @initialized = false

      def self.init
        PixeruInputHAL.init
        @initialized = true
        @registered_pins = {}
        @button_map.each_value do |pin|
          _register_pin(pin)
        end
      end

      def self.read_all
        state = {}
        @button_map.each do |button, pin|
          state[button] = true if PixeruInputHAL.read_pin(pin)
        end
        state
      end

      def self.map(button, pin:)
        @button_map[button] = pin
        _register_pin(pin) if @initialized
      end

      def self.read_analog(pin)
        PixeruInputHAL.read_analog(pin)
      end

      def self.shutdown
        PixeruInputHAL.shutdown
        @initialized = false
        @registered_pins = {}
      end

      def self._register_pin(pin)
        return if @registered_pins[pin]
        PixeruInputHAL.add_pin(pin)
        @registered_pins[pin] = true
      end
    end
  end
end
