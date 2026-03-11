require "test_helper"
require "pixeru/vec2"

# Default values
v = Pixeru::Vec2.new
assert_equal(0, v.x, "default x")
assert_equal(0, v.y, "default y")

# Addition
assert_equal(Pixeru::Vec2.new(4, 6), Pixeru::Vec2.new(1, 2) + Pixeru::Vec2.new(3, 4), "+")
assert_equal(Pixeru::Vec2.new(4, 6), Pixeru::Vec2.new(1, 2).add(Pixeru::Vec2.new(3, 4)), "add")

# Subtraction
assert_equal(Pixeru::Vec2.new(3, 2), Pixeru::Vec2.new(5, 3) - Pixeru::Vec2.new(2, 1), "-")
assert_equal(Pixeru::Vec2.new(3, 2), Pixeru::Vec2.new(5, 3).sub(Pixeru::Vec2.new(2, 1)), "sub")

# Scalar multiplication
assert_equal(Pixeru::Vec2.new(6, 9), Pixeru::Vec2.new(2, 3) * 3, "*")
assert_equal(Pixeru::Vec2.new(6, 9), Pixeru::Vec2.new(2, 3).scale(3), "scale")

# Length
assert_in_delta(5.0, Pixeru::Vec2.new(3, 4).length, 0.001, "length (3,4)")

# Dot product
assert_equal(0, Pixeru::Vec2.new(1, 0).dot(Pixeru::Vec2.new(0, 1)), "dot perpendicular")
assert_equal(23, Pixeru::Vec2.new(2, 3).dot(Pixeru::Vec2.new(4, 5)), "dot (2,3).(4,5)")

# Normalize zero vector
n = Pixeru::Vec2.new(0, 0).normalize
assert_equal(Pixeru::Vec2.new(0, 0), n, "normalize zero")

# Normalize unit length
assert_in_delta(1.0, Pixeru::Vec2.new(3, 4).normalize.length, 0.001, "normalize length")

# Distance
assert_in_delta(5.0, Pixeru::Vec2.new(0, 0).distance_to(Pixeru::Vec2.new(3, 4)), 0.001, "distance_to")
assert_in_delta(0.0, Pixeru::Vec2.new(2, 3).distance_to(Pixeru::Vec2.new(2, 3)), 0.001, "distance_to same")

# to_s
assert_equal("Vec2(1, 2)", Pixeru::Vec2.new(1, 2).to_s, "to_s")

# Inequality
assert(!(Pixeru::Vec2.new(1, 2) == Pixeru::Vec2.new(3, 4)), "not equal")

test_summary
