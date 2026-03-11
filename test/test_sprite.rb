require "test_helper"
require "pixeru/colour"
require "pixeru/frame_buffer"
require "pixeru/rect"
require "pixeru/sprite"

module Pixeru
  class Window
    @fb = Pixeru::FrameBuffer.new(32, 32)
    def self.frame_buffer
      @fb
    end
  end
end

fb = Pixeru::Window.frame_buffer
white = Pixeru::Colour::WHITE.to_rgb565
red = Pixeru::Colour::RED.to_rgb565

# Basic sprite draw
data = Array.new(4 * 4, white)
sprite = Pixeru::Sprite.new(data: data, width: 4, height: 4)
sprite.x = 2
sprite.y = 2
fb.clear
sprite.draw
assert_equal(white, fb.get_pixel(2, 2), "sprite draw top-left")
assert_equal(white, fb.get_pixel(5, 5), "sprite draw bottom-right")
assert_equal(0, fb.get_pixel(1, 1), "sprite draw outside")

# Transparent pixels are skipped
data2 = [white, 0x0000, 0x0000, white]
sprite2 = Pixeru::Sprite.new(data: data2, width: 2, height: 2)
sprite2.x = 0
sprite2.y = 0
fb.clear
sprite2.draw
assert_equal(white, fb.get_pixel(0, 0), "transparent skip: opaque")
assert_equal(0, fb.get_pixel(1, 0), "transparent skip: transparent")

# Invisible sprite does not draw
sprite.visible = false
fb.clear
sprite.draw
assert_equal(0, fb.get_pixel(2, 2), "invisible sprite not drawn")

# from_raw
sprite3 = Pixeru::Sprite.from_raw(data: data, width: 4, height: 4)
assert_equal(4, sprite3.width, "from_raw width")
assert_equal(4, sprite3.height, "from_raw height")

# collides_with?
a = Pixeru::Sprite.new(data: data, width: 4, height: 4)
a.x = 0; a.y = 0
b = Pixeru::Sprite.new(data: data, width: 4, height: 4)
b.x = 2; b.y = 2
assert(a.collides_with?(b), "collision overlapping")

c = Pixeru::Sprite.new(data: data, width: 4, height: 4)
c.x = 10; c.y = 10
assert(!a.collides_with?(c), "no collision")

# Clipping: sprite partially off-screen does not crash
sprite.visible = true
sprite.x = -2
sprite.y = -2
fb.clear
sprite.draw
assert(true, "clipping did not crash")

# SpriteSheet
sheet_data = Array.new(8 * 4, 0)
4.times { |i| sheet_data[i] = red }
sheet = Pixeru::Sprite.from_sheet(
  data: sheet_data,
  sheet_width: 8,
  frame_width: 4,
  frame_height: 4
)
assert_equal(2, sheet.frame_count, "sprite sheet frame count")
assert_equal(0, sheet.current_frame, "initial frame")
sheet.advance_frame
assert_equal(1, sheet.current_frame, "advance frame")
sheet.advance_frame
assert_equal(0, sheet.current_frame, "advance wraps")

# animate
sheet2 = Pixeru::Sprite.from_sheet(
  data: sheet_data,
  sheet_width: 8,
  frame_width: 4,
  frame_height: 4
)
sheet2.animate(speed: 3)
assert_equal(0, sheet2.current_frame, "animate not yet")
sheet2.animate(speed: 3)
assert_equal(0, sheet2.current_frame, "animate not yet 2")
sheet2.animate(speed: 3)
assert_equal(1, sheet2.current_frame, "animate advanced")

test_summary
