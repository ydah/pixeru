module Pixeru
  module HAL
  end
end

case RUBY_ENGINE
when "mruby/c"
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
else
  module Pixeru
    module HAL
      module Display
        @width = 0
        @height = 0

        def self.init(width, height)
          @width = width
          @height = height
          STDOUT.write "\e[?25l"
          STDOUT.write "\e[2J"
        end

        def self.send_buffer(buffer, width, height)
          STDOUT.write "\e[H"
          out = ""
          y = 0
          while y < height
            x = 0
            while x < width
              top = buffer[y * width + x]
              bottom = (y + 1 < height) ? buffer[(y + 1) * width + x] : 0
              tr, tg, tb = _rgb565_to_rgb(top)
              br, bg, bb = _rgb565_to_rgb(bottom)
              out << "\e[38;2;#{tr};#{tg};#{tb}m\e[48;2;#{br};#{bg};#{bb}m\u2580"
              x += 1
            end
            out << "\e[0m\n"
            y += 2
          end
          STDOUT.write out
        end

        def self.shutdown
          STDOUT.write "\e[?25h"
          STDOUT.write "\e[0m"
          STDOUT.write "\e[2J"
          STDOUT.write "\e[H"
        end

        def self._rgb565_to_rgb(c)
          r = ((c >> 11) & 0x1F) * 255 / 31
          g = ((c >> 5) & 0x3F) * 255 / 63
          b = (c & 0x1F) * 255 / 31
          [r, g, b]
        end
      end

      module Input
        @raw_mode = false

        def self.init
          _enable_raw_mode
        end

        def self.read_all
          state = {}
          data = _read_nonblock
          return state unless data

          i = 0
          while i < data.length
            ch = data[i]
            if ch == "\e" && (i + 2) < data.length && data[i + 1] == "["
              case data[i + 2]
              when "A" then state[:up] = true
              when "B" then state[:down] = true
              when "C" then state[:right] = true
              when "D" then state[:left] = true
              end
              i += 3
            else
              case ch
              when "z" then state[:a] = true
              when "x" then state[:b] = true
              when "\r", "\n" then state[:start] = true
              when "\e" then Pixeru::Scene.close!
              end
              i += 1
            end
          end
          state
        end

        def self.map(button, pin:)
        end

        def self.shutdown
          _disable_raw_mode
        end

        def self._enable_raw_mode
          return if @raw_mode
          if RUBY_ENGINE == "ruby"
            @old_tty = `stty -g`.chomp
            system("stty raw -echo")
          end
          @raw_mode = true
        end

        def self._disable_raw_mode
          return unless @raw_mode
          if RUBY_ENGINE == "ruby"
            system("stty #{@old_tty}") if @old_tty
          end
          @raw_mode = false
        end

        def self._read_nonblock
          if RUBY_ENGINE == "ruby"
            begin
              STDIN.read_nonblock(64)
            rescue IO::WaitReadable, EOFError
              nil
            end
          end
        end
      end

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
end
