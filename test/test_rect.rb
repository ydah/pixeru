require "test_helper"
require "pixeru/rect"

# contains?
rect = Pixeru::Rect.new(10, 20, 100, 50)
assert(rect.contains?(50, 40), "contains? inside")
assert(!rect.contains?(0, 0), "contains? outside")
assert(rect.contains?(10, 20), "contains? top-left corner")
assert(rect.contains?(110, 70), "contains? bottom-right corner")

# intersects?
a = Pixeru::Rect.new(0, 0, 10, 10)
b = Pixeru::Rect.new(5, 5, 10, 10)
assert(a.intersects?(b), "intersects? overlapping")
assert(b.intersects?(a), "intersects? reverse")

c = Pixeru::Rect.new(20, 20, 10, 10)
assert(!a.intersects?(c), "intersects? no overlap")

d = Pixeru::Rect.new(10, 0, 10, 10)
assert(!a.intersects?(d), "intersects? adjacent edge")

# intersection
result = a.intersection(b)
assert_equal(Pixeru::Rect.new(5, 5, 5, 5), result, "intersection rect")
assert_nil(a.intersection(c), "intersection nil")
assert_nil(a.intersection(d), "intersection adjacent nil")

# Equality
assert(Pixeru::Rect.new(1, 2, 3, 4) == Pixeru::Rect.new(1, 2, 3, 4), "== equal")
assert(!(Pixeru::Rect.new(1, 2, 3, 4) == Pixeru::Rect.new(1, 2, 3, 5)), "== different")

# to_s
assert_equal("Rect(1, 2, 3, 4)", Pixeru::Rect.new(1, 2, 3, 4).to_s, "to_s")

# right / bottom
r = Pixeru::Rect.new(5, 10, 20, 30)
assert_equal(25, r.right, "right")
assert_equal(40, r.bottom, "bottom")

test_summary
