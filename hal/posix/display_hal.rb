module Pixeru
  module HAL
    module Display
      @width = 0
      @height = 0

      def self.init(width, height)
        @width = width
        @height = height
        STDOUT.write "\e[?25l"  # hide cursor
        STDOUT.write "\e[2J"    # clear screen
      end

      # Render RGB565 framebuffer to terminal using half-block characters
      # Each terminal row represents 2 pixel rows
      def self.send_buffer(buffer, width, height)
        STDOUT.write "\e[H"  # move cursor to top-left
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
        STDOUT.write "\e[?25h"  # show cursor
        STDOUT.write "\e[0m"    # reset colours
        STDOUT.write "\e[2J"    # clear screen
        STDOUT.write "\e[H"     # move cursor to top-left
      end

      def self._rgb565_to_rgb(c)
        r = ((c >> 11) & 0x1F) * 255 / 31
        g = ((c >> 5) & 0x3F) * 255 / 63
        b = (c & 0x1F) * 255 / 31
        [r, g, b]
      end
    end
  end
end
