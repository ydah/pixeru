module Pixeru
  class Rect
    attr_accessor :x, :y, :width, :height

    def initialize(x, y, width, height)
      @x = x
      @y = y
      @width = width
      @height = height
    end

    def right
      @x + @width
    end

    def bottom
      @y + @height
    end

    def contains?(px, py)
      px >= @x && px <= right && py >= @y && py <= bottom
    end

    def intersects?(other)
      @x < other.right && right > other.x && @y < other.bottom && bottom > other.y
    end

    def intersection(other)
      return nil unless intersects?(other)

      ix = @x > other.x ? @x : other.x
      iy = @y > other.y ? @y : other.y
      ir = right < other.right ? right : other.right
      ib = bottom < other.bottom ? bottom : other.bottom

      Rect.new(ix, iy, ir - ix, ib - iy)
    end

    def ==(other)
      return false unless other.is_a?(Rect)
      @x == other.x && @y == other.y && @width == other.width && @height == other.height
    end

    def to_s
      "Rect(#{@x}, #{@y}, #{@width}, #{@height})"
    end
  end
end
