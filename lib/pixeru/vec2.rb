module Pixeru
  class Vec2
    attr_accessor :x, :y

    def initialize(x = 0, y = 0)
      @x = x
      @y = y
    end

    def +(other)
      Vec2.new(@x + other.x, @y + other.y)
    end

    def -(other)
      Vec2.new(@x - other.x, @y - other.y)
    end

    def *(scalar)
      Vec2.new(@x * scalar, @y * scalar)
    end

    def add(other)
      Vec2.new(@x + other.x, @y + other.y)
    end

    def sub(other)
      Vec2.new(@x - other.x, @y - other.y)
    end

    def scale(scalar)
      Vec2.new(@x * scalar, @y * scalar)
    end

    # Fallback for environments without Math.sqrt:
    #   def _isqrt(n)
    #     return 0 if n <= 0
    #     g = n
    #     loop do
    #       g2 = (g + n / g) / 2
    #       break if g2 >= g
    #       g = g2
    #     end
    #     g
    #   end
    def length
      Math.sqrt(@x * @x + @y * @y)
    end

    def normalize
      len = length
      return Vec2.new(0, 0) if len == 0
      Vec2.new(@x / len.to_f, @y / len.to_f)
    end

    def dot(other)
      @x * other.x + @y * other.y
    end

    def distance_to(other)
      dx = @x - other.x
      dy = @y - other.y
      Math.sqrt(dx * dx + dy * dy)
    end

    def ==(other)
      other.is_a?(Vec2) && @x == other.x && @y == other.y
    end

    def to_s
      "Vec2(#{@x}, #{@y})"
    end
  end
end
