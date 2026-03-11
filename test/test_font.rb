require "test_helper"
require "pixeru/colour"
require "pixeru/frame_buffer"
require "pixeru/font_data"
require "pixeru/font"

# Stub Window.frame_buffer
module Pixeru
  class Window
    @fb = Pixeru::FrameBuffer.new(160, 128)
    def self.frame_buffer
      @fb
    end
  end
end

fb = Pixeru::Window.frame_buffer
font = Pixeru::Font.default

# Drawing "A" should write pixels
fb.clear
font.draw("A", x: 0, y: 0, colour: Pixeru::Colour::WHITE)
has_pixel = false
7.times do |row|
  5.times do |col|
    if fb.get_pixel(col, row) != 0
      has_pixel = true
    end
  end
end
assert(has_pixel, "drawing 'A' writes pixels")

# measure
w = font.measure("Hello", scale: 1)
assert_equal(5 * (5 + 1), w, "measure 'Hello' width")

# measure with newline
w = font.measure("AB\nCDE", scale: 1)
assert_equal(3 * (5 + 1), w, "measure multiline width")

# scale 2
w2 = font.measure("A", scale: 2)
assert_equal((5 + 1) * 2, w2, "measure scale 2")

# Drawing with scale 2 writes larger pixels
fb.clear
font.draw("A", x: 0, y: 0, colour: Pixeru::Colour::WHITE, scale: 2)
has_scaled = false
14.times do |row|
  10.times do |col|
    if fb.get_pixel(col, row) != 0
      has_scaled = true
    end
  end
end
assert(has_scaled, "scale 2 writes pixels")

test_summary
