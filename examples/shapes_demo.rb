require "pixeru"

Pixeru::Window.open(width: 160, height: 128, fps: 30)

def main
  Pixeru::Input.update

  Pixeru::Window.draw do
    Pixeru::Window.clear(colour: Pixeru::Colour::BLACK)

    Pixeru::Shape.draw_rect(
      x: 5, y: 5, width: 30, height: 20,
      colour: Pixeru::Colour::RED, fill: true
    )

    Pixeru::Shape.draw_rect(
      x: 40, y: 5, width: 30, height: 20,
      colour: Pixeru::Colour::GREEN, fill: false
    )

    Pixeru::Shape.draw_circle(
      x: 30, y: 60, radius: 20,
      colour: Pixeru::Colour::BLUE, fill: true
    )

    Pixeru::Shape.draw_circle(
      x: 90, y: 60, radius: 20,
      colour: Pixeru::Colour::CYAN, fill: false
    )

    Pixeru::Shape.draw_line(
      x1: 0, y1: 100, x2: 159, y2: 100,
      colour: Pixeru::Colour::YELLOW
    )

    Pixeru::Shape.draw_triangle(
      x1: 120, y1: 10, x2: 100, y2: 50, x3: 140, y3: 50,
      colour: Pixeru::Colour::MAGENTA
    )

    Pixeru::Font.default.draw(
      "Shapes Demo",
      x: 40, y: 110,
      colour: Pixeru::Colour::WHITE
    )
  end
end

main until Pixeru::Scene.close?
Pixeru::Window.close
