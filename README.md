# Pixeru

Pixeru is a small 2D game engine for PicoRuby and CRuby-based POSIX development.

It is written mostly in Ruby, keeps the API compact, and is inspired by Taylor's style of game loop and drawing primitives. The repository now supports both of these use cases:

- CRuby development on POSIX with `require "pixeru"`
- PicoRuby firmware builds via a root `mrbgem.rake`

## Current Status

- Core API is implemented: `Window`, `Colour`, `Vec2`, `Rect`, `FrameBuffer`, `Shape`, `Font`, `Input`, `Timer`, `Scene`, `Sprite`, `Audio`
- POSIX development uses a terminal renderer in [`hal/posix`](hal/posix)
- PicoRuby packaging is prepared through [`mrbgem.rake`](mrbgem.rake), [`mrblib`](mrblib), and [`src`](src)
- RP2040 HAL wrappers exist, but actual board wiring and display configuration are still project-specific

## Install

### CRuby / POSIX

Build and install the gem locally:

```bash
gem build pixeru.gemspec
gem install ./pixeru-0.1.0.gem
```

Or run directly from this repository:

```bash
ruby -I lib examples/hello_world.rb
```

### PicoRuby

Add this repository to your PicoRuby build config:

```ruby
conf.gem github: "YOUR_GITHUB_USER/pixeru"
```

For local integration without pushing first:

```ruby
conf.gem File.expand_path("../pixeru", __dir__)
```

PicoRuby consumes this repository as an `mrbgem`. RubyGems publication is optional and mainly useful for CRuby development, tooling, and CI.

## Quick Start

For CRuby or POSIX development:

```ruby
require "pixeru"

Pixeru::Window.open(width: 160, height: 128, fps: 30)

def main
  Pixeru::Input.update

  Pixeru::Window.draw do
    Pixeru::Window.clear(colour: Pixeru::Colour::BLACK)

    Pixeru::Font.default.draw(
      "Hello Pixeru!",
      x: 20, y: 10,
      colour: Pixeru::Colour::WHITE
    )

    Pixeru::Shape.draw_rect(
      x: 40, y: 40,
      width: 80,
      height: 50,
      colour: Pixeru::Colour::RED
    )
  end
end

main until Pixeru::Scene.close?
Pixeru::Window.close
```

For RP2040 targets, map your buttons and audio pin before starting the loop:

```ruby
Pixeru::Input.map(Pixeru::Input::A, pin: 2)
Pixeru::Input.map(Pixeru::Input::B, pin: 3)
Pixeru::Input.map(Pixeru::Input::START, pin: 4)
Pixeru::Audio.open(pin: 15)
```

## Examples

- [`examples/hello_world.rb`](examples/hello_world.rb): minimal drawing loop
- [`examples/shapes_demo.rb`](examples/shapes_demo.rb): primitives and text
- [`examples/input_demo.rb`](examples/input_demo.rb): keyboard-driven movement on POSIX
- [`examples/simple_game.rb`](examples/simple_game.rb): scene-based sample game

Run an example from the repository root:

```bash
ruby -I lib examples/shapes_demo.rb
```

## Development

Smoke test the public entrypoint:

```bash
ruby -I lib -e 'require "pixeru"; puts Pixeru::VERSION'
```

Run all tests:

```bash
for f in test/test_*.rb; do ruby -I lib -I test "$f"; done
```

Build the gem package:

```bash
gem build pixeru.gemspec
```

CI is defined in [`.github/workflows/ci.yml`](.github/workflows/ci.yml) and covers:

- CRuby test matrix
- gem packaging
- PicoRuby POSIX build with this repository included as a local `mrbgem`

## Project Layout

- [`lib/pixeru`](lib/pixeru): main Ruby API
- [`hal/posix`](hal/posix): terminal-based development HAL
- [`hal/rp2040`](hal/rp2040): RP2040 HAL wrappers and legacy C sources
- [`mrblib`](mrblib): PicoRuby-side Ruby glue for the `mrbgem`
- [`src`](src): PicoRuby C entrypoints
- [`examples`](examples): runnable demos
- [`test`](test): lightweight test suite
- [`tools`](tools): asset conversion helpers

## Notes and Limitations

- The POSIX renderer currently targets ANSI-capable terminals, not SDL or a native window
- The design docs still describe some planned work that is not fully reflected in the runtime yet
- Dirty-region optimization is not yet wired through the active rendering path
- RP2040 display and pin assignments are intentionally not hard-coded at the README level beyond small examples

## License

[MIT License](LICENSE)
