require "pixeru"

Pixeru::Window.open(width: 160, height: 128, fps: 30)

player_x = 80
player_y = 64
speed = 2

def main(px, py, spd)
  Pixeru::Input.update

  px -= spd if Pixeru::Input.pressed?(Pixeru::Input::LEFT)
  px += spd if Pixeru::Input.pressed?(Pixeru::Input::RIGHT)
  py -= spd if Pixeru::Input.pressed?(Pixeru::Input::UP)
  py += spd if Pixeru::Input.pressed?(Pixeru::Input::DOWN)

  px = 0 if px < 0
  px = 150 if px > 150
  py = 0 if py < 0
  py = 118 if py > 118

  Pixeru::Window.draw do
    Pixeru::Window.clear(colour: Pixeru::Colour::BLACK)

    Pixeru::Shape.draw_rect(
      x: px, y: py, width: 10, height: 10,
      colour: Pixeru::Colour::GREEN
    )

    Pixeru::Font.default.draw(
      "Arrow keys: move\nESC: quit",
      x: 5, y: 5,
      colour: Pixeru::Colour::WHITE
    )
  end

  [px, py]
end

until Pixeru::Scene.close?
  player_x, player_y = main(player_x, player_y, speed)
end
Pixeru::Window.close
