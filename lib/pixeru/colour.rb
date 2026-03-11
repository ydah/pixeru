module Pixeru
  class Colour
    attr_reader :r, :g, :b, :a

    def initialize(r, g, b, a = 255)
      @r = _clamp(r, 0, 255)
      @g = _clamp(g, 0, 255)
      @b = _clamp(b, 0, 255)
      @a = _clamp(a, 0, 255)
    end

    def to_rgb565
      ((@r & 0xF8) << 8) | ((@g & 0xFC) << 3) | (@b >> 3)
    end

    def ==(other)
      return false unless other.respond_to?(:r)
      @r == other.r && @g == other.g && @b == other.b && @a == other.a
    end

    def to_s
      "Colour(#{@r}, #{@g}, #{@b}, #{@a})"
    end

    def _clamp(val, min, max)
      return min if val < min
      return max if val > max
      val
    end

    BLACK       = Colour.new(0, 0, 0)
    WHITE       = Colour.new(255, 255, 255)
    RED         = Colour.new(255, 0, 0)
    GREEN       = Colour.new(0, 255, 0)
    BLUE        = Colour.new(0, 0, 255)
    YELLOW      = Colour.new(255, 255, 0)
    CYAN        = Colour.new(0, 255, 255)
    MAGENTA     = Colour.new(255, 0, 255)
    GRAY        = Colour.new(128, 128, 128)
    DARKGRAY    = Colour.new(80, 80, 80)
    TRANSPARENT = Colour.new(0, 0, 0, 0)
  end
end
