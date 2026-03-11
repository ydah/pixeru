module Pixeru
  module Audio
    NOTE_FREQUENCIES = {
      "C" => [262, 523, 1047],
      "D" => [294, 587, 1175],
      "E" => [330, 659, 1319],
      "F" => [349, 698, 1397],
      "G" => [392, 784, 1568],
      "A" => [440, 880, 1760],
      "B" => [494, 988, 1976],
    }

    @volume = 100
    @playing = false

    def self.open(pin: nil)
      HAL::Audio.init(pin)
      @playing = false
    end

    def self.tone(frequency:, duration:)
      HAL::Audio.tone(frequency, duration)
    end

    # MML-like melody string: "C4D4E4F4G4A4B4C5" or "R4" for rest
    def self.play(melody)
      @playing = true
      i = 0
      while i < melody.length
        break unless @playing
        ch = melody[i]

        if ch == "R" || ch == "r"
          duration = _parse_duration(melody, i + 1)
          i += 1 + _digit_length(melody, i + 1)
          sleep(duration / 1000.0) if RUBY_ENGINE == "ruby"
          next
        end

        note = ch.upcase
        freqs = NOTE_FREQUENCIES[note]
        if freqs
          octave = 4
          ni = i + 1
          if ni < melody.length && melody[ni] >= "0" && melody[ni] <= "9"
            octave = melody[ni].to_i
            ni += 1
          end
          freq_idx = octave - 4
          freq_idx = 0 if freq_idx < 0
          freq_idx = freqs.length - 1 if freq_idx >= freqs.length
          freq = freqs[freq_idx]

          duration = _parse_duration(melody, ni)
          i = ni + _digit_length(melody, ni)

          HAL::Audio.tone(freq, duration)
          sleep(duration / 1000.0) if RUBY_ENGINE == "ruby"
        else
          i += 1
        end
      end
    end

    def self.stop
      @playing = false
      HAL::Audio.stop
    end

    def self.volume=(val)
      @volume = val < 0 ? 0 : (val > 100 ? 100 : val)
    end

    def self.volume
      @volume
    end

    def self.close
      stop
      HAL::Audio.shutdown
    end

    def self._parse_duration(str, pos)
      len = _digit_length(str, pos)
      return 250 if len == 0
      str[pos, len].to_i
    end

    def self._digit_length(str, pos)
      count = 0
      while pos < str.length && str[pos] >= "0" && str[pos] <= "9"
        count += 1
        pos += 1
      end
      count
    end
  end
end
