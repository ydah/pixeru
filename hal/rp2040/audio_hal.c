/*
 * Pixeru RP2040 Audio HAL
 * PWM-based tone generation
 */

#include "mrubyc.h"
#include "hardware/pwm.h"
#include "hardware/gpio.h"
#include "hardware/clocks.h"

static uint8_t audio_pin = 0;
static uint audio_slice = 0;
static uint audio_channel = 0;

static void c_audio_init(mrbc_vm *vm, mrbc_value *v, int argc) {
  audio_pin = (uint8_t)mrbc_integer(v[1]);

  gpio_set_function(audio_pin, GPIO_FUNC_PWM);
  audio_slice = pwm_gpio_to_slice_num(audio_pin);
  audio_channel = pwm_gpio_to_channel(audio_pin);

  pwm_set_enabled(audio_slice, false);
}

static void c_audio_tone(mrbc_vm *vm, mrbc_value *v, int argc) {
  uint32_t frequency = (uint32_t)mrbc_integer(v[1]);
  uint32_t duration  = (uint32_t)mrbc_integer(v[2]);

  if (frequency == 0) return;

  uint32_t clock = clock_get_hz(clk_sys);
  uint32_t wrap = clock / frequency;
  uint32_t div = 1;

  while (wrap > 65535) {
    div++;
    wrap = clock / (frequency * div);
  }

  pwm_set_clkdiv(audio_slice, (float)div);
  pwm_set_wrap(audio_slice, (uint16_t)wrap);
  pwm_set_chan_level(audio_slice, audio_channel, wrap / 2);  /* 50% duty */
  pwm_set_enabled(audio_slice, true);

  sleep_ms(duration);

  pwm_set_enabled(audio_slice, false);
}

static void c_audio_stop(mrbc_vm *vm, mrbc_value *v, int argc) {
  pwm_set_enabled(audio_slice, false);
}

static void c_audio_shutdown(mrbc_vm *vm, mrbc_value *v, int argc) {
  pwm_set_enabled(audio_slice, false);
}

void pixeru_audio_hal_init(mrbc_vm *vm) {
  mrbc_class *cls = mrbc_define_class(vm, "AudioHAL", mrbc_class_object);
  mrbc_define_method(vm, cls, "init",     c_audio_init);
  mrbc_define_method(vm, cls, "tone",     c_audio_tone);
  mrbc_define_method(vm, cls, "stop",     c_audio_stop);
  mrbc_define_method(vm, cls, "shutdown", c_audio_shutdown);
}
