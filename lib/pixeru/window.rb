module Pixeru
  class Window
    @fb = nil
    @width = 0
    @height = 0
    @target_fps = 30
    @last_frame_time = nil
    @delta_time = 0
    @frame_count = 0
    @fps_timer = nil
    @measured_fps = 0

    def self.open(width:, height:, title: "Pixeru", fps: 30)
      @width = width
      @height = height
      @target_fps = fps
      @fb = FrameBuffer.new(width, height)
      @last_frame_time = Time.now
      @fps_timer = Time.now
      @frame_count = 0
      @measured_fps = 0
      HAL::Display.init(width, height)
      HAL::Input.init
    end

    def self.draw
      frame_start = Time.now
      @delta_time = ((frame_start - @last_frame_time) * 1000).to_i
      @last_frame_time = frame_start

      yield

      HAL::Display.send_buffer(@fb.raw_buffer, @width, @height)
      @fb.clear_dirty

      @frame_count += 1
      elapsed = Time.now - @fps_timer
      if elapsed >= 1.0
        @measured_fps = @frame_count
        @frame_count = 0
        @fps_timer = Time.now
      end

      frame_time = Time.now - frame_start
      target_time = 1.0 / @target_fps
      if frame_time < target_time
        sleep(target_time - frame_time)
      end
    end

    def self.clear(colour: Colour::BLACK)
      @fb.clear(colour.to_rgb565)
    end

    def self.close
      HAL::Input.shutdown
      HAL::Display.shutdown
    end

    def self.width
      @width
    end

    def self.height
      @height
    end

    def self.fps
      @measured_fps
    end

    def self.target_fps=(val)
      @target_fps = val
    end

    def self.delta_time
      @delta_time
    end

    def self.frame_buffer
      @fb
    end
  end
end
