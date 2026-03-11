module Pixeru
  class Scene
    @@current_scene = nil
    @@should_close = false

    def self.current
      @@current_scene
    end

    def self.switch(scene)
      @@current_scene.on_exit if @@current_scene
      @@current_scene = scene
      @@current_scene.on_enter if @@current_scene
    end

    def self.close?
      @@should_close
    end

    def self.close!
      @@should_close = true
    end

    def self.reset
      @@current_scene = nil
      @@should_close = false
    end

    def on_enter
    end

    def on_exit
    end

    def update(dt)
    end

    def draw
    end
  end
end
