/*
 * Pixeru RP2040 Input HAL
 * GPIO button input with pull-up and debounce
 */

#include "mrubyc.h"
#include "hardware/gpio.h"
#include "hardware/adc.h"

#define MAX_BUTTONS 8
#define DEBOUNCE_MS 20

typedef struct {
  uint8_t pin;
  bool    active;
  bool    last_raw;
  uint32_t last_change;
} button_state_t;

static button_state_t buttons[MAX_BUTTONS];
static int button_count = 0;

static void c_input_init(mrbc_vm *vm, mrbc_value *v, int argc) {
  button_count = 0;
  adc_init();
}

static void c_input_add_pin(mrbc_vm *vm, mrbc_value *v, int argc) {
  if (button_count >= MAX_BUTTONS) return;

  uint8_t pin = (uint8_t)mrbc_integer(v[1]);

  gpio_init(pin);
  gpio_set_dir(pin, GPIO_IN);
  gpio_pull_up(pin);

  buttons[button_count].pin = pin;
  buttons[button_count].active = false;
  buttons[button_count].last_raw = false;
  buttons[button_count].last_change = 0;
  button_count++;
}

static void c_input_read_pin(mrbc_vm *vm, mrbc_value *v, int argc) {
  uint8_t pin = (uint8_t)mrbc_integer(v[1]);

  for (int i = 0; i < button_count; i++) {
    if (buttons[i].pin == pin) {
      bool raw = !gpio_get(pin);  /* Active low with pull-up */
      uint32_t now = to_ms_since_boot(get_absolute_time());

      if (raw != buttons[i].last_raw) {
        buttons[i].last_change = now;
        buttons[i].last_raw = raw;
      }

      if ((now - buttons[i].last_change) >= DEBOUNCE_MS) {
        buttons[i].active = buttons[i].last_raw;
      }

      SET_BOOL_RETURN(buttons[i].active);
      return;
    }
  }
  SET_BOOL_RETURN(0);
}

static void c_input_read_analog(mrbc_vm *vm, mrbc_value *v, int argc) {
  uint8_t pin = (uint8_t)mrbc_integer(v[1]);

  uint8_t adc_input = pin - 26;  /* GP26=ADC0, GP27=ADC1, GP28=ADC2 */
  if (adc_input > 2) {
    SET_INT_RETURN(0);
    return;
  }

  adc_gpio_init(pin);
  adc_select_input(adc_input);
  uint16_t result = adc_read();

  SET_INT_RETURN(result);
}

static void c_input_shutdown(mrbc_vm *vm, mrbc_value *v, int argc) {
  button_count = 0;
}

void pixeru_input_hal_init(mrbc_vm *vm) {
  mrbc_class *cls = mrbc_define_class(vm, "InputHAL", mrbc_class_object);
  mrbc_define_method(vm, cls, "init",         c_input_init);
  mrbc_define_method(vm, cls, "add_pin",      c_input_add_pin);
  mrbc_define_method(vm, cls, "read_pin",     c_input_read_pin);
  mrbc_define_method(vm, cls, "read_analog",  c_input_read_analog);
  mrbc_define_method(vm, cls, "shutdown",     c_input_shutdown);
}
