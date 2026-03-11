require_relative "lib/pixeru/version"

Gem::Specification.new do |spec|
  spec.name = "pixeru"
  spec.version = Pixeru::VERSION
  spec.authors = ["Yudai Takada"]
  spec.summary = "Pure Ruby 2D game engine for PicoRuby"
  spec.description = "Pixeru provides a small 2D game engine API for PicoRuby and CRuby-based POSIX development."
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1"

  spec.files = Dir[
    "LICENSE",
    "README.md",
    "hal/**/*.rb",
    "lib/**/*.rb",
    "mrbgem.rake",
    "mrblib/**/*.rb",
    "src/**/*.c",
    "tools/*.rb"
  ]
  spec.require_paths = ["lib"]
  spec.extra_rdoc_files = ["README.md", "LICENSE"]
  spec.metadata["rubygems_mfa_required"] = "true"
end
