module Pixeru
  module HAL
    module Input
      @raw_mode = false

      def self.init
        _enable_raw_mode
      end

      def self.read_all
        state = {}
        data = _read_nonblock
        return state unless data

        i = 0
        while i < data.length
          ch = data[i]
          if ch == "\e" && (i + 2) < data.length && data[i + 1] == "["
            case data[i + 2]
            when "A" then state[:up] = true
            when "B" then state[:down] = true
            when "C" then state[:right] = true
            when "D" then state[:left] = true
            end
            i += 3
          else
            case ch
            when "z" then state[:a] = true
            when "x" then state[:b] = true
            when "\r", "\n" then state[:start] = true
            when "\e" then Pixeru::Scene.close!
            end
            i += 1
          end
        end
        state
      end

      def self.shutdown
        _disable_raw_mode
      end

      def self._enable_raw_mode
        return if @raw_mode
        case RUBY_ENGINE
        when "ruby"
          @old_tty = `stty -g`.chomp
          system("stty raw -echo")
        end
        @raw_mode = true
      end

      def self._disable_raw_mode
        return unless @raw_mode
        case RUBY_ENGINE
        when "ruby"
          system("stty #{@old_tty}") if @old_tty
        end
        @raw_mode = false
      end

      def self._read_nonblock
        case RUBY_ENGINE
        when "ruby"
          begin
            STDIN.read_nonblock(64)
          rescue IO::WaitReadable, EOFError
            nil
          end
        else
          nil
        end
      end
    end
  end
end
