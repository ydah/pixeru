module Pixeru
  module Input
    UP     = :up
    DOWN   = :down
    LEFT   = :left
    RIGHT  = :right
    A      = :a
    B      = :b
    START  = :start
    SELECT = :select

    @current_state = {}
    @previous_state = {}
    @pin_map = {}

    def self.update
      @previous_state = {}
      @current_state.each do |k, v|
        @previous_state[k] = v
      end
      @current_state = HAL::Input.read_all
    end

    def self.pressed?(button)
      @current_state[button] == true
    end

    def self.just_pressed?(button)
      @current_state[button] == true && @previous_state[button] != true
    end

    def self.just_released?(button)
      @current_state[button] != true && @previous_state[button] == true
    end

    def self.map(button, pin:)
      @pin_map[button] = pin
      HAL::Input.map(button, pin) if HAL::Input.respond_to?(:map)
    end

    def self.reset
      @current_state = {}
      @previous_state = {}
    end
  end
end
