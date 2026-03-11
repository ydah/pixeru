module Pixeru
  module Shape
    def self.draw_pixel(x:, y:, colour:)
      fb = Window.frame_buffer
      fb.set_pixel(x, y, colour.to_rgb565)
    end

    # Bresenham's line algorithm (integer arithmetic only)
    def self.draw_line(x1:, y1:, x2:, y2:, colour:)
      fb = Window.frame_buffer
      c = colour.to_rgb565

      dx = (x2 - x1).abs
      dy = -(y2 - y1).abs
      sx = x1 < x2 ? 1 : -1
      sy = y1 < y2 ? 1 : -1
      err = dx + dy

      loop do
        fb.set_pixel(x1, y1, c)
        break if x1 == x2 && y1 == y2

        e2 = 2 * err
        if e2 >= dy
          err += dy
          x1 += sx
        end
        if e2 <= dx
          err += dx
          y1 += sy
        end
      end
    end

    def self.draw_rect(x:, y:, width:, height:, colour:, fill: true)
      fb = Window.frame_buffer
      c = colour.to_rgb565

      if fill
        fb.fill_rect(x, y, width, height, c)
      else
        _hline(fb, x, x + width - 1, y, c)
        _hline(fb, x, x + width - 1, y + height - 1, c)
        _vline(fb, x, y, y + height - 1, c)
        _vline(fb, x + width - 1, y, y + height - 1, c)
      end
    end

    # Midpoint circle algorithm (Bresenham)
    def self.draw_circle(x:, y:, radius:, colour:, fill: true)
      fb = Window.frame_buffer
      c = colour.to_rgb565

      cx = 0
      cy = radius
      d = 1 - radius

      if fill
        while cx <= cy
          _hline(fb, x - cy, x + cy, y + cx, c)
          _hline(fb, x - cy, x + cy, y - cx, c)
          _hline(fb, x - cx, x + cx, y + cy, c)
          _hline(fb, x - cx, x + cx, y - cy, c)

          if d < 0
            d += 2 * cx + 3
          else
            d += 2 * (cx - cy) + 5
            cy -= 1
          end
          cx += 1
        end
      else
        while cx <= cy
          fb.set_pixel(x + cx, y + cy, c)
          fb.set_pixel(x - cx, y + cy, c)
          fb.set_pixel(x + cx, y - cy, c)
          fb.set_pixel(x - cx, y - cy, c)
          fb.set_pixel(x + cy, y + cx, c)
          fb.set_pixel(x - cy, y + cx, c)
          fb.set_pixel(x + cy, y - cx, c)
          fb.set_pixel(x - cy, y - cx, c)

          if d < 0
            d += 2 * cx + 3
          else
            d += 2 * (cx - cy) + 5
            cy -= 1
          end
          cx += 1
        end
      end
    end

    def self.draw_triangle(x1:, y1:, x2:, y2:, x3:, y3:, colour:, fill: false)
      draw_line(x1: x1, y1: y1, x2: x2, y2: y2, colour: colour)
      draw_line(x1: x2, y1: y2, x2: x3, y2: y3, colour: colour)
      draw_line(x1: x3, y1: y3, x2: x1, y2: y1, colour: colour)
    end

    def self._hline(fb, x1, x2, y, c)
      x1, x2 = x2, x1 if x1 > x2
      while x1 <= x2
        fb.set_pixel(x1, y, c)
        x1 += 1
      end
    end

    def self._vline(fb, x, y1, y2, c)
      y1, y2 = y2, y1 if y1 > y2
      while y1 <= y2
        fb.set_pixel(x, y1, c)
        y1 += 1
      end
    end
  end
end
