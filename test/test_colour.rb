require "test_helper"
require "pixeru/colour"

# Colour constants
assert_equal(0,   Pixeru::Colour::BLACK.r, "BLACK.r")
assert_equal(0,   Pixeru::Colour::BLACK.g, "BLACK.g")
assert_equal(0,   Pixeru::Colour::BLACK.b, "BLACK.b")
assert_equal(255, Pixeru::Colour::BLACK.a, "BLACK.a")

assert_equal(255, Pixeru::Colour::WHITE.r, "WHITE.r")
assert_equal(255, Pixeru::Colour::WHITE.g, "WHITE.g")
assert_equal(255, Pixeru::Colour::WHITE.b, "WHITE.b")

assert_equal(255, Pixeru::Colour::RED.r, "RED.r")
assert_equal(0,   Pixeru::Colour::RED.g, "RED.g")
assert_equal(0,   Pixeru::Colour::RED.b, "RED.b")

assert_equal(0,   Pixeru::Colour::GREEN.r, "GREEN.r")
assert_equal(255, Pixeru::Colour::GREEN.g, "GREEN.g")
assert_equal(0,   Pixeru::Colour::GREEN.b, "GREEN.b")

assert_equal(0,   Pixeru::Colour::BLUE.r, "BLUE.r")
assert_equal(0,   Pixeru::Colour::BLUE.g, "BLUE.g")
assert_equal(255, Pixeru::Colour::BLUE.b, "BLUE.b")

assert_equal(0, Pixeru::Colour::TRANSPARENT.a, "TRANSPARENT.a")

# to_rgb565
assert_equal(0xFFFF, Pixeru::Colour::WHITE.to_rgb565, "WHITE.to_rgb565")
assert_equal(0x0000, Pixeru::Colour::BLACK.to_rgb565, "BLACK.to_rgb565")
assert_equal(0xF800, Pixeru::Colour::RED.to_rgb565,   "RED.to_rgb565")
assert_equal(0x07E0, Pixeru::Colour::GREEN.to_rgb565, "GREEN.to_rgb565")
assert_equal(0x001F, Pixeru::Colour::BLUE.to_rgb565,  "BLUE.to_rgb565")

# Equality
c1 = Pixeru::Colour.new(10, 20, 30)
c2 = Pixeru::Colour.new(10, 20, 30)
c3 = Pixeru::Colour.new(10, 20, 31)
assert(c1 == c2, "equal colours")
assert(!(c1 == c3), "different colours")
assert(!(c1 == "not a colour"), "non-Colour comparison")

# Clamping
clamped = Pixeru::Colour.new(300, -10, 128, 999)
assert_equal(255, clamped.r, "clamp r=300")
assert_equal(0,   clamped.g, "clamp g=-10")
assert_equal(128, clamped.b, "clamp b=128")
assert_equal(255, clamped.a, "clamp a=999")

# to_s
assert_equal("Colour(10, 20, 30, 255)", Pixeru::Colour.new(10, 20, 30).to_s, "to_s")

test_summary
