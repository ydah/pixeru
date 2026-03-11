require "test_helper"
require "pixeru/colour"
require "pixeru/frame_buffer"
require "pixeru/shape"

# Stub Window.frame_buffer
module Pixeru
  class Window
    @fb = Pixeru::FrameBuffer.new(32, 32)
    def self.frame_buffer
      @fb
    end
  end
end

fb = Pixeru::Window.frame_buffer
white = Pixeru::Colour::WHITE
red = Pixeru::Colour::RED

# draw_pixel
fb.clear
Pixeru::Shape.draw_pixel(x: 5, y: 5, colour: white)
assert_equal(white.to_rgb565, fb.get_pixel(5, 5), "draw_pixel")

# Horizontal line
fb.clear
Pixeru::Shape.draw_line(x1: 0, y1: 5, x2: 10, y2: 5, colour: white)
assert_equal(white.to_rgb565, fb.get_pixel(0, 5), "hline start")
assert_equal(white.to_rgb565, fb.get_pixel(10, 5), "hline end")
assert_equal(white.to_rgb565, fb.get_pixel(5, 5), "hline mid")

# Vertical line
fb.clear
Pixeru::Shape.draw_line(x1: 5, y1: 0, x2: 5, y2: 10, colour: white)
assert_equal(white.to_rgb565, fb.get_pixel(5, 0), "vline start")
assert_equal(white.to_rgb565, fb.get_pixel(5, 10), "vline end")

# Filled rect
fb.clear
Pixeru::Shape.draw_rect(x: 2, y: 2, width: 4, height: 4, colour: red, fill: true)
assert_equal(red.to_rgb565, fb.get_pixel(2, 2), "fill rect inside")
assert_equal(red.to_rgb565, fb.get_pixel(5, 5), "fill rect corner")
assert_equal(0, fb.get_pixel(1, 1), "fill rect outside")

# Outline rect
fb.clear
Pixeru::Shape.draw_rect(x: 2, y: 2, width: 5, height: 5, colour: white, fill: false)
assert_equal(white.to_rgb565, fb.get_pixel(2, 2), "outline top-left")
assert_equal(white.to_rgb565, fb.get_pixel(6, 2), "outline top-right")
assert_equal(white.to_rgb565, fb.get_pixel(2, 6), "outline bottom-left")
assert_equal(0, fb.get_pixel(4, 4), "outline interior empty")

# Circle (filled)
fb.clear
Pixeru::Shape.draw_circle(x: 16, y: 16, radius: 5, colour: white, fill: true)
assert_equal(white.to_rgb565, fb.get_pixel(16, 16), "circle center")
assert_equal(0, fb.get_pixel(0, 0), "circle outside")

# Circle (outline)
fb.clear
Pixeru::Shape.draw_circle(x: 16, y: 16, radius: 5, colour: white, fill: false)
assert_equal(0, fb.get_pixel(16, 16), "circle outline center empty")

# Clipping: drawing off-screen should not crash
fb.clear
Pixeru::Shape.draw_line(x1: -10, y1: -10, x2: 50, y2: 50, colour: white)
Pixeru::Shape.draw_rect(x: -5, y: -5, width: 10, height: 10, colour: red)
Pixeru::Shape.draw_circle(x: 0, y: 0, radius: 20, colour: white)
assert(true, "clipping did not crash")

test_summary
