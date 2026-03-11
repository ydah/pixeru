module Pixeru
end

require "pixeru/colour"
require "pixeru/vec2"
require "pixeru/rect"
require "pixeru/timer"
require "pixeru/scene"
require "pixeru/frame_buffer"
require "pixeru/font_data"
require "pixeru/font"
require "pixeru/input"
require "pixeru/shape"
require "pixeru/sprite"
require "pixeru/audio"
require "pixeru/window"

base_dir = File.expand_path("../..", __dir__)

case RUBY_ENGINE
when "ruby", "mruby"
  require File.join(base_dir, "hal/posix/display_hal")
  require File.join(base_dir, "hal/posix/input_hal")
  require File.join(base_dir, "hal/posix/audio_hal")
when "mruby/c"
  require File.join(base_dir, "hal/rp2040/display_hal")
  require File.join(base_dir, "hal/rp2040/input_hal")
  require File.join(base_dir, "hal/rp2040/audio_hal")
else
  raise LoadError, "unsupported RUBY_ENGINE: #{RUBY_ENGINE}"
end
