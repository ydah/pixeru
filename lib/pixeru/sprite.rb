module Pixeru
  class Sprite
    attr_accessor :x, :y, :width, :height, :visible
    attr_accessor :scale_x, :scale_y, :rotation
    attr_reader :transparent_colour

    def initialize(data:, width:, height:, transparent: 0x0000)
      @x = 0
      @y = 0
      @width = width
      @height = height
      @scale_x = 1
      @scale_y = 1
      @rotation = 0
      @visible = true
      @data = data
      @transparent_colour = transparent
    end

    def self.from_raw(data:, width:, height:)
      Sprite.new(data: data, width: width, height: height)
    end

    def self.from_sheet(data:, sheet_width:, frame_width:, frame_height:)
      cols = sheet_width / frame_width
      rows = data.length / (sheet_width * frame_height)
      frames = []

      row = 0
      while row < rows
        col = 0
        while col < cols
          frame_data = Array.new(frame_width * frame_height, 0)
          fy = 0
          while fy < frame_height
            fx = 0
            while fx < frame_width
              src_idx = (row * frame_height + fy) * sheet_width + (col * frame_width + fx)
              frame_data[fy * frame_width + fx] = data[src_idx]
              fx += 1
            end
            fy += 1
          end
          frames << frame_data
          col += 1
        end
        row += 1
      end

      SpriteSheet.new(
        frames: frames,
        frame_width: frame_width,
        frame_height: frame_height
      )
    end

    def draw
      return unless @visible
      fb = Window.frame_buffer
      return if @x + @width <= 0 || @x >= fb.width
      return if @y + @height <= 0 || @y >= fb.height

      sy = 0
      while sy < @height
        dy = @y + sy
        if dy >= 0 && dy < fb.height
          sx = 0
          while sx < @width
            dx = @x + sx
            if dx >= 0 && dx < fb.width
              pixel = @data[sy * @width + sx]
              fb.set_pixel(dx, dy, pixel) if pixel != @transparent_colour
            end
            sx += 1
          end
        end
        sy += 1
      end
    end

    def collides_with?(other)
      return false unless @visible && other.visible
      !(@x + @width <= other.x ||
        other.x + other.width <= @x ||
        @y + @height <= other.y ||
        other.y + other.height <= @y)
    end
  end

  class SpriteSheet
    attr_accessor :x, :y, :visible
    attr_reader :frame_width, :frame_height, :frame_count, :current_frame

    def initialize(frames:, frame_width:, frame_height:)
      @frames = frames
      @frame_width = frame_width
      @frame_height = frame_height
      @frame_count = frames.length
      @current_frame = 0
      @x = 0
      @y = 0
      @visible = true
      @anim_counter = 0
    end

    def advance_frame
      @current_frame = (@current_frame + 1) % @frame_count
    end

    def animate(speed:)
      @anim_counter += 1
      if @anim_counter >= speed
        advance_frame
        @anim_counter = 0
      end
    end

    def draw
      return unless @visible
      fb = Window.frame_buffer
      data = @frames[@current_frame]
      return unless data

      sy = 0
      while sy < @frame_height
        dy = @y + sy
        if dy >= 0 && dy < fb.height
          sx = 0
          while sx < @frame_width
            dx = @x + sx
            if dx >= 0 && dx < fb.width
              pixel = data[sy * @frame_width + sx]
              fb.set_pixel(dx, dy, pixel) if pixel != 0x0000
            end
            sx += 1
          end
        end
        sy += 1
      end
    end

    def width
      @frame_width
    end

    def height
      @frame_height
    end
  end
end
