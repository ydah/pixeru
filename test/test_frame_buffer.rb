require "test_helper"
require "pixeru/frame_buffer"

fb = Pixeru::FrameBuffer.new(16, 16)

# set/get pixel
fb.set_pixel(5, 5, 0xF800)
assert_equal(0xF800, fb.get_pixel(5, 5), "set/get pixel")

# Out-of-bounds write is safe
fb.set_pixel(-1, 0, 0xFFFF)
fb.set_pixel(0, -1, 0xFFFF)
fb.set_pixel(16, 0, 0xFFFF)
fb.set_pixel(0, 16, 0xFFFF)
assert_equal(0, fb.get_pixel(-1, 0), "get out-of-bounds returns 0")

# Clear
fb.set_pixel(3, 3, 0xFFFF)
fb.clear(0x0000)
assert_equal(0, fb.get_pixel(3, 3), "clear resets pixels")
assert_equal(0, fb.get_pixel(5, 5), "clear resets all")

# fill_rect
fb.clear
fb.fill_rect(2, 2, 4, 4, 0x07E0)
assert_equal(0x07E0, fb.get_pixel(2, 2), "fill_rect top-left")
assert_equal(0x07E0, fb.get_pixel(5, 5), "fill_rect bottom-right")
assert_equal(0, fb.get_pixel(1, 1), "fill_rect outside")
assert_equal(0, fb.get_pixel(6, 6), "fill_rect outside2")

# fill_rect clipping
fb.clear
fb.fill_rect(-2, -2, 5, 5, 0x001F)
assert_equal(0x001F, fb.get_pixel(0, 0), "fill_rect clipped origin")
assert_equal(0x001F, fb.get_pixel(2, 2), "fill_rect clipped inside")
assert_equal(0, fb.get_pixel(3, 3), "fill_rect clipped outside")

# Dirty regions
fb.clear_dirty
fb.mark_dirty(0, 0, 10, 10)
assert_equal(1, fb.dirty_regions.length, "dirty count 1")
fb.clear_dirty
assert_equal(0, fb.dirty_regions.length, "dirty cleared")

# Dirty region overflow merges to full screen
fb.clear_dirty
9.times do |i|
  fb.mark_dirty(i, i, 1, 1)
end
assert_equal(1, fb.dirty_regions.length, "dirty overflow merged")
assert_equal([0, 0, 16, 16], fb.dirty_regions[0], "dirty overflow is full screen")

# raw_buffer
assert_equal(16 * 16, fb.raw_buffer.length, "raw_buffer length")

test_summary
