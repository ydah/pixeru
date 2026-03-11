require "pixeru"

Pixeru::Window.open(width: 160, height: 128, fps: 30)

def main
  Pixeru::Input.update

  if Pixeru::Input.just_pressed?(Pixeru::Input::A)
    # A button pressed
  end

  Pixeru::Window.draw do
    Pixeru::Window.clear(colour: Pixeru::Colour::BLACK)

    Pixeru::Font.default.draw(
      "Hello Pixeru!",
      x: 20, y: 10,
      colour: Pixeru::Colour::WHITE
    )

    Pixeru::Shape.draw_rect(
      x: 40, y: 40, width: 80, height: 50,
      colour: Pixeru::Colour::RED
    )

    Pixeru::Shape.draw_circle(
      x: 80, y: 90, radius: 15,
      colour: Pixeru::Colour::YELLOW
    )
  end
end

main until Pixeru::Scene.close?
Pixeru::Window.close
