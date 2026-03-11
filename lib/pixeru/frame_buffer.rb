module Pixeru
  class FrameBuffer
    attr_reader :width, :height

    MAX_DIRTY_REGIONS = 8

    def initialize(width, height)
      @width = width
      @height = height
      @buffer = Array.new(width * height, 0)
      @dirty_regions = []
    end

    def set_pixel(x, y, colour_rgb565)
      return if x < 0 || x >= @width || y < 0 || y >= @height
      @buffer[y * @width + x] = colour_rgb565
    end

    def get_pixel(x, y)
      return 0 if x < 0 || x >= @width || y < 0 || y >= @height
      @buffer[y * @width + x]
    end

    def clear(colour_rgb565 = 0)
      i = 0
      len = @buffer.length
      while i < len
        @buffer[i] = colour_rgb565
        i += 1
      end
    end

    def fill_rect(x, y, w, h, colour_rgb565)
      x0 = x < 0 ? 0 : x
      y0 = y < 0 ? 0 : y
      x1 = (x + w) > @width ? @width : (x + w)
      y1 = (y + h) > @height ? @height : (y + h)

      row = y0
      while row < y1
        col = x0
        offset = row * @width
        while col < x1
          @buffer[offset + col] = colour_rgb565
          col += 1
        end
        row += 1
      end
    end

    def raw_buffer
      @buffer
    end

    def mark_dirty(x, y, w, h)
      if @dirty_regions.length >= MAX_DIRTY_REGIONS
        @dirty_regions = [[0, 0, @width, @height]]
      else
        @dirty_regions << [x, y, w, h]
      end
    end

    def dirty_regions
      @dirty_regions
    end

    def clear_dirty
      @dirty_regions = []
    end
  end
end
