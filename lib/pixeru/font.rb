module Pixeru
  class Font
    CHAR_SPACING = 1

    def self.default
      @default ||= Font.new(
        data: FontData::DEFAULT_5X7,
        char_width: 5,
        char_height: 7
      )
    end

    def initialize(data:, char_width:, char_height:)
      @data = data
      @char_width = char_width
      @char_height = char_height
    end

    def draw(text, x:, y:, colour: Colour::WHITE, scale: 1)
      fb = Window.frame_buffer
      c = colour.to_rgb565
      cursor_x = x
      cursor_y = y

      i = 0
      while i < text.length
        ch = text[i]
        if ch == "\n"
          cursor_x = x
          cursor_y += (@char_height + 1) * scale
          i += 1
          next
        end

        code = ch.ord
        glyph = @data[code]
        if glyph
          _draw_glyph(fb, glyph, cursor_x, cursor_y, c, scale)
        end
        cursor_x += (@char_width + CHAR_SPACING) * scale
        i += 1
      end
    end

    def measure(text, scale: 1)
      max_width = 0
      current_width = 0

      i = 0
      while i < text.length
        if text[i] == "\n"
          max_width = current_width if current_width > max_width
          current_width = 0
        else
          current_width += (@char_width + CHAR_SPACING) * scale
        end
        i += 1
      end
      max_width = current_width if current_width > max_width
      max_width
    end

    def _draw_glyph(fb, glyph, gx, gy, colour_rgb565, scale)
      col = 0
      while col < @char_width
        bits = glyph[col]
        row = 0
        while row < @char_height
          if (bits >> row) & 1 == 1
            if scale == 1
              fb.set_pixel(gx + col, gy + row, colour_rgb565)
            else
              sy = 0
              while sy < scale
                sx = 0
                while sx < scale
                  fb.set_pixel(gx + col * scale + sx, gy + row * scale + sy, colour_rgb565)
                  sx += 1
                end
                sy += 1
              end
            end
          end
          row += 1
        end
        col += 1
      end
    end
  end
end
