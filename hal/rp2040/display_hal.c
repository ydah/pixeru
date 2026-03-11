/*
 * Pixeru RP2040 Display HAL
 * ST7789 / ILI9341 SPI LCD driver
 */

#include "mrubyc.h"
#include "hardware/spi.h"
#include "hardware/gpio.h"
#include "hardware/dma.h"

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

static int dma_channel = -1;
static uint16_t lcd_width = 0;
static uint16_t lcd_height = 0;

static void lcd_write_cmd(uint8_t cmd) {
  gpio_put(PIN_DC, 0);
  gpio_put(PIN_CS, 0);
  spi_write_blocking(LCD_SPI, &cmd, 1);
  gpio_put(PIN_CS, 1);
}

static void lcd_write_data(const uint8_t *data, size_t len) {
  gpio_put(PIN_DC, 1);
  gpio_put(PIN_CS, 0);
  spi_write_blocking(LCD_SPI, data, len);
  gpio_put(PIN_CS, 1);
}

static void lcd_write_data_byte(uint8_t val) {
  lcd_write_data(&val, 1);
}

static void lcd_set_window(uint16_t x0, uint16_t y0, uint16_t x1, uint16_t y1) {
  uint8_t buf[4];

  lcd_write_cmd(CMD_CASET);
  buf[0] = x0 >> 8; buf[1] = x0 & 0xFF;
  buf[2] = x1 >> 8; buf[3] = x1 & 0xFF;
  lcd_write_data(buf, 4);

  lcd_write_cmd(CMD_RASET);
  buf[0] = y0 >> 8; buf[1] = y0 & 0xFF;
  buf[2] = y1 >> 8; buf[3] = y1 & 0xFF;
  lcd_write_data(buf, 4);

  lcd_write_cmd(CMD_RAMWR);
}

static void c_display_init(mrbc_vm *vm, mrbc_value *v, int argc) {
  lcd_width  = mrbc_integer(v[1]);
  lcd_height = mrbc_integer(v[2]);

  spi_init(LCD_SPI, 62500000);  /* 62.5 MHz */
  gpio_set_function(PIN_SCK,  GPIO_FUNC_SPI);
  gpio_set_function(PIN_MOSI, GPIO_FUNC_SPI);

  gpio_init(PIN_CS);  gpio_set_dir(PIN_CS,  GPIO_OUT); gpio_put(PIN_CS,  1);
  gpio_init(PIN_DC);  gpio_set_dir(PIN_DC,  GPIO_OUT);
  gpio_init(PIN_RST); gpio_set_dir(PIN_RST, GPIO_OUT);
  gpio_init(PIN_BL);  gpio_set_dir(PIN_BL,  GPIO_OUT);

  /* Hardware reset */
  gpio_put(PIN_RST, 0);
  sleep_ms(100);
  gpio_put(PIN_RST, 1);
  sleep_ms(100);

  lcd_write_cmd(CMD_SLPOUT);
  sleep_ms(120);

  lcd_write_cmd(CMD_MADCTL);
  lcd_write_data_byte(0x70);  /* Row/column exchange for landscape */

  lcd_write_cmd(CMD_COLMOD);
  lcd_write_data_byte(0x05);  /* 16-bit RGB565 */

  lcd_write_cmd(CMD_DISPON);

  gpio_put(PIN_BL, 1);  /* Backlight on */

  /* Init DMA channel */
  dma_channel = dma_claim_unused_channel(true);
  dma_channel_config c = dma_channel_get_default_config(dma_channel);
  channel_config_set_transfer_data_size(&c, DMA_SIZE_16);
  channel_config_set_dreq(&c, spi_get_dreq(LCD_SPI, true));
  dma_channel_configure(dma_channel, &c, &spi_get_hw(LCD_SPI)->dr, NULL, 0, false);
}

static void c_display_send_buffer(mrbc_vm *vm, mrbc_value *v, int argc) {
  mrbc_value arr = v[1];
  int width  = mrbc_integer(v[2]);
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

static void c_display_shutdown(mrbc_vm *vm, mrbc_value *v, int argc) {
  gpio_put(PIN_BL, 0);
  if (dma_channel >= 0) {
    dma_channel_unclaim(dma_channel);
    dma_channel = -1;
  }
}

void pixeru_display_hal_init(mrbc_vm *vm) {
  mrbc_class *cls = mrbc_define_class(vm, "DisplayHAL", mrbc_class_object);
  mrbc_define_method(vm, cls, "init",        c_display_init);
  mrbc_define_method(vm, cls, "send_buffer", c_display_send_buffer);
  mrbc_define_method(vm, cls, "shutdown",    c_display_shutdown);
}
