require "pixeru"

SCREEN_W = 160
SCREEN_H = 128
PLAYER_SIZE = 8
OBSTACLE_SIZE = 10
SPEED = 2

class TitleScene < Pixeru::Scene
  def update(dt)
    Pixeru::Input.update
    if Pixeru::Input.just_pressed?(Pixeru::Input::START) ||
       Pixeru::Input.just_pressed?(Pixeru::Input::A)
      Pixeru::Scene.switch(GameScene.new)
    end
  end

  def draw
    Pixeru::Window.draw do
      Pixeru::Window.clear(colour: Pixeru::Colour::BLACK)
      Pixeru::Font.default.draw(
        "SIMPLE GAME",
        x: 35, y: 40,
        colour: Pixeru::Colour::YELLOW, scale: 2
      )
      Pixeru::Font.default.draw(
        "Press A or START",
        x: 25, y: 80,
        colour: Pixeru::Colour::WHITE
      )
    end
  end
end

class GameScene < Pixeru::Scene
  def on_enter
    @player_x = SCREEN_W / 2 - PLAYER_SIZE / 2
    @player_y = SCREEN_H - PLAYER_SIZE - 4
    @score = 0
    @obstacles = []
    @spawn_timer = 0
  end

  def update(dt)
    Pixeru::Input.update

    @player_x -= SPEED if Pixeru::Input.pressed?(Pixeru::Input::LEFT)
    @player_x += SPEED if Pixeru::Input.pressed?(Pixeru::Input::RIGHT)
    @player_x = 0 if @player_x < 0
    @player_x = SCREEN_W - PLAYER_SIZE if @player_x > SCREEN_W - PLAYER_SIZE

    @spawn_timer += 1
    if @spawn_timer >= 20
      @spawn_timer = 0
      ox = (@score * 37 + @obstacles.length * 53) % (SCREEN_W - OBSTACLE_SIZE)
      @obstacles << { x: ox, y: -OBSTACLE_SIZE }
    end

    i = 0
    while i < @obstacles.length
      @obstacles[i][:y] += 1
      i += 1
    end

    @obstacles = @obstacles.select { |o| o[:y] < SCREEN_H }

    player_rect = Pixeru::Rect.new(@player_x, @player_y, PLAYER_SIZE, PLAYER_SIZE)
    @obstacles.each do |o|
      obs_rect = Pixeru::Rect.new(o[:x], o[:y], OBSTACLE_SIZE, OBSTACLE_SIZE)
      if player_rect.intersects?(obs_rect)
        Pixeru::Scene.switch(GameOverScene.new(@score))
        return
      end
    end

    @score += 1
  end

  def draw
    Pixeru::Window.draw do
      Pixeru::Window.clear(colour: Pixeru::Colour::BLACK)

      Pixeru::Shape.draw_rect(
        x: @player_x, y: @player_y,
        width: PLAYER_SIZE, height: PLAYER_SIZE,
        colour: Pixeru::Colour::GREEN
      )

      @obstacles.each do |o|
        Pixeru::Shape.draw_rect(
          x: o[:x], y: o[:y],
          width: OBSTACLE_SIZE, height: OBSTACLE_SIZE,
          colour: Pixeru::Colour::RED
        )
      end

      Pixeru::Font.default.draw(
        "Score: #{@score}",
        x: 2, y: 2,
        colour: Pixeru::Colour::WHITE
      )
    end
  end
end

class GameOverScene < Pixeru::Scene
  def initialize(score)
    @final_score = score
  end

  def update(dt)
    Pixeru::Input.update
    if Pixeru::Input.just_pressed?(Pixeru::Input::A) ||
       Pixeru::Input.just_pressed?(Pixeru::Input::START)
      Pixeru::Scene.switch(TitleScene.new)
    end
  end

  def draw
    Pixeru::Window.draw do
      Pixeru::Window.clear(colour: Pixeru::Colour::DARKGRAY)
      Pixeru::Font.default.draw(
        "GAME OVER",
        x: 40, y: 40,
        colour: Pixeru::Colour::RED, scale: 2
      )
      Pixeru::Font.default.draw(
        "Score: #{@final_score}",
        x: 45, y: 75,
        colour: Pixeru::Colour::WHITE
      )
      Pixeru::Font.default.draw(
        "Press A to retry",
        x: 25, y: 100,
        colour: Pixeru::Colour::YELLOW
      )
    end
  end
end

Pixeru::Window.open(width: SCREEN_W, height: SCREEN_H, fps: 30)
Pixeru::Scene.switch(TitleScene.new)

until Pixeru::Scene.close?
  scene = Pixeru::Scene.current
  if scene
    scene.update(Pixeru::Window.delta_time)
    scene.draw
  end
end

Pixeru::Window.close
