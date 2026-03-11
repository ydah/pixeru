MRuby::Gem::Specification.new("pixeru-hal-rp2040") do |spec|
  spec.license = "MIT"
  spec.author  = "Pixeru contributors"
  spec.summary = "Pixeru HAL for RP2040 (display, input, audio)"

  spec.cc.include_paths << "#{spec.dir}/include"
end
