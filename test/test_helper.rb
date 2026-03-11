$test_count = 0
$fail_count = 0

def assert(condition, message = "")
  $test_count += 1
  unless condition
    $fail_count += 1
    puts "FAIL: #{message}"
  end
end

def assert_equal(expected, actual, message = "")
  assert(expected == actual, "#{message} expected: #{expected}, got: #{actual}")
end

def assert_nil(actual, message = "")
  assert(actual == nil, "#{message} expected nil, got: #{actual}")
end

def assert_not_nil(actual, message = "")
  assert(actual != nil, "#{message} expected not nil")
end

def assert_in_delta(expected, actual, delta = 0.001, message = "")
  assert((expected - actual).abs < delta, "#{message} expected: #{expected} +/- #{delta}, got: #{actual}")
end

def test_summary
  puts "#{$test_count} tests, #{$fail_count} failures"
  exit(1) if $fail_count > 0
end
