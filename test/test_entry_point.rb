require "test_helper"
require "pixeru"

assert_equal("0.1.0", Pixeru::VERSION, "version constant")
assert_not_nil(Pixeru::Colour::WHITE, "colour loaded")
assert_not_nil(Pixeru::Window, "window loaded")
assert_not_nil(Pixeru::HAL::Display, "display HAL loaded")

test_summary
