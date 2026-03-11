#include <mrubyc.h>
#include <stdint.h>
#include <stdbool.h>

#if defined(__has_include)
# if __has_include("hardware/adc.h") && __has_include("hardware/clocks.h") && __has_include("hardware/dma.h") && __has_include("hardware/gpio.h") && __has_include("hardware/pwm.h") && __has_include("hardware/spi.h") && __has_include("pico/time.h")
#  define PIXERU_HAS_PICO_SDK 1
# else
#  define PIXERU_HAS_PICO_SDK 0
# endif
#else
# define PIXERU_HAS_PICO_SDK 0
#endif

#if PIXERU_HAS_PICO_SDK

#include "hardware/adc.h"
#include "hardware/clocks.h"
#include "hardware/dma.h"
#include "hardware/gpio.h"
#include "hardware/pwm.h"
#include "hardware/spi.h"
#include "pico/time.h"

#define LCD_SPI       spi0
#define PIN_SCK       18
#define PIN_MOSI      19
#define PIN_CS        17
#define PIN_DC        16
#define PIN_RST       20
#define PIN_BL        21

#define CMD_CASET     0x2A
#define CMD_RASET     0x2B
#define CMD_RAMWR     0x2C
#define CMD_SLPOUT    0x11
#define CMD_DISPON    0x29
#define CMD_MADCTL    0x36
#define CMD_COLMOD    0x3A

#define MAX_BUTTONS   8
#define DEBOUNCE_MS   20

typedef struct {
  uint8_t pin;
  bool active;
  bool last_raw;
  uint32_t last_change;
} button_state_t;

static int dma_channel = -1;
static uint16_t lcd_width = 0;
static uint16_t lcd_height = 0;

static button_state_t buttons[MAX_BUTTONS];
static int button_count = 0;

static uint8_t audio_pin = 0;
static uint audio_slice = 0;
static uint audio_channel = 0;

static void
lcd_write_cmd(uint8_t cmd)
{
  gpio_put(PIN_DC, 0);
  gpio_put(PIN_CS, 0);
  spi_write_blocking(LCD_SPI, &cmd, 1);
  gpio_put(PIN_CS, 1);
}

static void
lcd_write_data(const uint8_t *data, size_t len)
{
  gpio_put(PIN_DC, 1);
  gpio_put(PIN_CS, 0);
  spi_write_blocking(LCD_SPI, data, len);
  gpio_put(PIN_CS, 1);
}

static void
lcd_write_data_byte(uint8_t val)
{
  lcd_write_data(&val, 1);
}

static void
lcd_set_window(uint16_t x0, uint16_t y0, uint16_t x1, uint16_t y1)
{
  uint8_t buf[4];

  lcd_write_cmd(CMD_CASET);
  buf[0] = x0 >> 8;
  buf[1] = x0 & 0xFF;
  buf[2] = x1 >> 8;
  buf[3] = x1 & 0xFF;
  lcd_write_data(buf, 4);

  lcd_write_cmd(CMD_RASET);
  buf[0] = y0 >> 8;
  buf[1] = y0 & 0xFF;
  buf[2] = y1 >> 8;
  buf[3] = y1 & 0xFF;
  lcd_write_data(buf, 4);

  lcd_write_cmd(CMD_RAMWR);
}

static void
c_display_init(mrbc_vm *vm, mrbc_value *v, int argc)
{
  (void)vm;
  (void)argc;

  lcd_width = mrbc_integer(v[1]);
  lcd_height = mrbc_integer(v[2]);

  spi_init(LCD_SPI, 62500000);
  gpio_set_function(PIN_SCK, GPIO_FUNC_SPI);
  gpio_set_function(PIN_MOSI, GPIO_FUNC_SPI);

  gpio_init(PIN_CS);
  gpio_set_dir(PIN_CS, GPIO_OUT);
  gpio_put(PIN_CS, 1);

  gpio_init(PIN_DC);
  gpio_set_dir(PIN_DC, GPIO_OUT);

  gpio_init(PIN_RST);
  gpio_set_dir(PIN_RST, GPIO_OUT);

  gpio_init(PIN_BL);
  gpio_set_dir(PIN_BL, GPIO_OUT);

  gpio_put(PIN_RST, 0);
  sleep_ms(100);
  gpio_put(PIN_RST, 1);
  sleep_ms(100);

  lcd_write_cmd(CMD_SLPOUT);
  sleep_ms(120);

  lcd_write_cmd(CMD_MADCTL);
  lcd_write_data_byte(0x70);

  lcd_write_cmd(CMD_COLMOD);
  lcd_write_data_byte(0x05);

  lcd_write_cmd(CMD_DISPON);
  gpio_put(PIN_BL, 1);

  dma_channel = dma_claim_unused_channel(true);
  dma_channel_config c = dma_channel_get_default_config(dma_channel);
  channel_config_set_transfer_data_size(&c, DMA_SIZE_16);
  channel_config_set_dreq(&c, spi_get_dreq(LCD_SPI, true));
  dma_channel_configure(dma_channel, &c, &spi_get_hw(LCD_SPI)->dr, NULL, 0, false);
}

static void
c_display_send_buffer(mrbc_vm *vm, mrbc_value *v, int argc)
{
  (void)vm;
  (void)argc;

  mrbc_value arr = v[1];
  int width = mrbc_integer(v[2]);
  int height = mrbc_integer(v[3]);

  lcd_set_window(0, 0, width - 1, height - 1);

  gpio_put(PIN_DC, 1);
  gpio_put(PIN_CS, 0);

  int len = width * height;
  for (int i = 0; i < len; i++) {
    mrbc_value pixel = mrbc_array_get(&arr, i);
    uint16_t c = (uint16_t)mrbc_integer(pixel);
    uint8_t hi = c >> 8;
    uint8_t lo = c & 0xFF;
    spi_write_blocking(LCD_SPI, &hi, 1);
    spi_write_blocking(LCD_SPI, &lo, 1);
  }

  gpio_put(PIN_CS, 1);
}

static void
c_display_shutdown(mrbc_vm *vm, mrbc_value *v, int argc)
{
  (void)vm;
  (void)v;
  (void)argc;

  gpio_put(PIN_BL, 0);
  if (dma_channel >= 0) {
    dma_channel_unclaim(dma_channel);
    dma_channel = -1;
  }
}

static void
c_input_init(mrbc_vm *vm, mrbc_value *v, int argc)
{
  (void)vm;
  (void)v;
  (void)argc;

  button_count = 0;
  adc_init();
}

static void
c_input_add_pin(mrbc_vm *vm, mrbc_value *v, int argc)
{
  (void)vm;
  (void)argc;

  if (button_count >= MAX_BUTTONS) {
    return;
  }

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

static void
c_input_read_pin(mrbc_vm *vm, mrbc_value *v, int argc)
{
  (void)argc;

  uint8_t pin = (uint8_t)mrbc_integer(v[1]);

  for (int i = 0; i < button_count; i++) {
    if (buttons[i].pin == pin) {
      bool raw = !gpio_get(pin);
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

  SET_BOOL_RETURN(false);
}

static void
c_input_read_analog(mrbc_vm *vm, mrbc_value *v, int argc)
{
  (void)vm;
  (void)argc;

  uint8_t pin = (uint8_t)mrbc_integer(v[1]);
  uint8_t adc_input = pin - 26;

  if (adc_input > 2) {
    SET_INT_RETURN(0);
    return;
  }

  adc_gpio_init(pin);
  adc_select_input(adc_input);
  SET_INT_RETURN(adc_read());
}

static void
c_input_shutdown(mrbc_vm *vm, mrbc_value *v, int argc)
{
  (void)vm;
  (void)v;
  (void)argc;

  button_count = 0;
}

static void
c_audio_init(mrbc_vm *vm, mrbc_value *v, int argc)
{
  (void)vm;

  audio_pin = (argc > 0 && mrbc_type(v[1]) == MRBC_TT_INTEGER) ? (uint8_t)mrbc_integer(v[1]) : 0;

  gpio_set_function(audio_pin, GPIO_FUNC_PWM);
  audio_slice = pwm_gpio_to_slice_num(audio_pin);
  audio_channel = pwm_gpio_to_channel(audio_pin);

  pwm_set_enabled(audio_slice, false);
}

static void
c_audio_tone(mrbc_vm *vm, mrbc_value *v, int argc)
{
  (void)vm;
  (void)argc;

  uint32_t frequency = (uint32_t)mrbc_integer(v[1]);
  uint32_t duration = (uint32_t)mrbc_integer(v[2]);

  if (frequency == 0) {
    return;
  }

  uint32_t clock = clock_get_hz(clk_sys);
  uint32_t wrap = clock / frequency;
  uint32_t div = 1;

  while (wrap > 65535) {
    div++;
    wrap = clock / (frequency * div);
  }

  pwm_set_clkdiv(audio_slice, (float)div);
  pwm_set_wrap(audio_slice, (uint16_t)wrap);
  pwm_set_chan_level(audio_slice, audio_channel, wrap / 2);
  pwm_set_enabled(audio_slice, true);

  sleep_ms(duration);
  pwm_set_enabled(audio_slice, false);
}

static void
c_audio_stop(mrbc_vm *vm, mrbc_value *v, int argc)
{
  (void)vm;
  (void)v;
  (void)argc;

  pwm_set_enabled(audio_slice, false);
}

static void
c_audio_shutdown(mrbc_vm *vm, mrbc_value *v, int argc)
{
  (void)vm;
  (void)v;
  (void)argc;

  pwm_set_enabled(audio_slice, false);
}

void
mrbc_pixeru_init(struct VM *vm)
{
  (void)vm;

  mrbc_class *display_hal = mrbc_define_class(0, "PixeruDisplayHAL", mrbc_class_object);
  mrbc_define_method(0, display_hal, "init", c_display_init);
  mrbc_define_method(0, display_hal, "send_buffer", c_display_send_buffer);
  mrbc_define_method(0, display_hal, "shutdown", c_display_shutdown);

  mrbc_class *input_hal = mrbc_define_class(0, "PixeruInputHAL", mrbc_class_object);
  mrbc_define_method(0, input_hal, "init", c_input_init);
  mrbc_define_method(0, input_hal, "add_pin", c_input_add_pin);
  mrbc_define_method(0, input_hal, "read_pin", c_input_read_pin);
  mrbc_define_method(0, input_hal, "read_analog", c_input_read_analog);
  mrbc_define_method(0, input_hal, "shutdown", c_input_shutdown);

  mrbc_class *audio_hal = mrbc_define_class(0, "PixeruAudioHAL", mrbc_class_object);
  mrbc_define_method(0, audio_hal, "init", c_audio_init);
  mrbc_define_method(0, audio_hal, "tone", c_audio_tone);
  mrbc_define_method(0, audio_hal, "stop", c_audio_stop);
  mrbc_define_method(0, audio_hal, "shutdown", c_audio_shutdown);
}

#else

static void
c_display_init(mrbc_vm *vm, mrbc_value *v, int argc)
{
  (void)vm;
  (void)v;
  (void)argc;
}

static void
c_display_send_buffer(mrbc_vm *vm, mrbc_value *v, int argc)
{
  (void)vm;
  (void)v;
  (void)argc;
}

static void
c_display_shutdown(mrbc_vm *vm, mrbc_value *v, int argc)
{
  (void)vm;
  (void)v;
  (void)argc;
}

static void
c_input_init(mrbc_vm *vm, mrbc_value *v, int argc)
{
  (void)vm;
  (void)v;
  (void)argc;
}

static void
c_input_add_pin(mrbc_vm *vm, mrbc_value *v, int argc)
{
  (void)vm;
  (void)v;
  (void)argc;
}

static void
c_input_read_pin(mrbc_vm *vm, mrbc_value *v, int argc)
{
  (void)vm;
  (void)v;
  (void)argc;
  SET_BOOL_RETURN(false);
}

static void
c_input_read_analog(mrbc_vm *vm, mrbc_value *v, int argc)
{
  (void)vm;
  (void)v;
  (void)argc;
  SET_INT_RETURN(0);
}

static void
c_input_shutdown(mrbc_vm *vm, mrbc_value *v, int argc)
{
  (void)vm;
  (void)v;
  (void)argc;
}

static void
c_audio_init(mrbc_vm *vm, mrbc_value *v, int argc)
{
  (void)vm;
  (void)v;
  (void)argc;
}

static void
c_audio_tone(mrbc_vm *vm, mrbc_value *v, int argc)
{
  (void)vm;
  (void)v;
  (void)argc;
}

static void
c_audio_stop(mrbc_vm *vm, mrbc_value *v, int argc)
{
  (void)vm;
  (void)v;
  (void)argc;
}

static void
c_audio_shutdown(mrbc_vm *vm, mrbc_value *v, int argc)
{
  (void)vm;
  (void)v;
  (void)argc;
}

void
mrbc_pixeru_init(struct VM *vm)
{
  (void)vm;

  mrbc_class *display_hal = mrbc_define_class(0, "PixeruDisplayHAL", mrbc_class_object);
  mrbc_define_method(0, display_hal, "init", c_display_init);
  mrbc_define_method(0, display_hal, "send_buffer", c_display_send_buffer);
  mrbc_define_method(0, display_hal, "shutdown", c_display_shutdown);

  mrbc_class *input_hal = mrbc_define_class(0, "PixeruInputHAL", mrbc_class_object);
  mrbc_define_method(0, input_hal, "init", c_input_init);
  mrbc_define_method(0, input_hal, "add_pin", c_input_add_pin);
  mrbc_define_method(0, input_hal, "read_pin", c_input_read_pin);
  mrbc_define_method(0, input_hal, "read_analog", c_input_read_analog);
  mrbc_define_method(0, input_hal, "shutdown", c_input_shutdown);

  mrbc_class *audio_hal = mrbc_define_class(0, "PixeruAudioHAL", mrbc_class_object);
  mrbc_define_method(0, audio_hal, "init", c_audio_init);
  mrbc_define_method(0, audio_hal, "tone", c_audio_tone);
  mrbc_define_method(0, audio_hal, "stop", c_audio_stop);
  mrbc_define_method(0, audio_hal, "shutdown", c_audio_shutdown);
}

#endif
