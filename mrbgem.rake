MRuby::Gem::Specification.new("picoruby-pixeru") do |spec|
  spec.license = "MIT"
  spec.author  = "Yudai Takada"
  spec.summary = "Pure Ruby 2D game engine for PicoRuby"

  spec.rbfiles = [
    "#{spec.dir}/lib/pixeru/version.rb",
    "#{spec.dir}/lib/pixeru/colour.rb",
    "#{spec.dir}/lib/pixeru/vec2.rb",
    "#{spec.dir}/lib/pixeru/rect.rb",
    "#{spec.dir}/lib/pixeru/timer.rb",
    "#{spec.dir}/lib/pixeru/scene.rb",
    "#{spec.dir}/lib/pixeru/frame_buffer.rb",
    "#{spec.dir}/lib/pixeru/font_data.rb",
    "#{spec.dir}/lib/pixeru/font.rb",
    "#{spec.dir}/lib/pixeru/input.rb",
    "#{spec.dir}/lib/pixeru/shape.rb",
    "#{spec.dir}/lib/pixeru/sprite.rb",
    "#{spec.dir}/lib/pixeru/audio.rb",
    "#{spec.dir}/lib/pixeru/window.rb",
    "#{spec.dir}/mrblib/pixeru_hal.rb",
  ]
end
