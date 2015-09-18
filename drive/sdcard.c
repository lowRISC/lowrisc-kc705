
#include "sdcard.h"

volatile uint32_t *spi_base_ptr = (uint32_t *)(SPI_BASE);

uint64_t sd_init() {
  uint64_t regValue;

  // software reset?
  *(spi_base_ptr + SPI_SRR) = 0xa;

  // set control register
  // MSB first, master, reset FIFOs, SPI disabled, clock 00 mode
  *(spi_base_ptr + SPI_CR) = 0xE4;
  
  // disable interrupt, full polling mode
  *(spi_base_ptr + SPI_GIER) = 0x0;

  // read status register
  regValue = (*(spi_base_ptr + SPI_SR)) & 0x7FF;
  if(regValue != 0x25) return(regValue); // something went wrong!

  // enable spi
  *(spi_base_ptr + SPI_CR) = 0x86;

  // give clocks to slave for it to boot
  spi_boot();

  // send the first CMD0 to reset
  spi_slave_enable();
  sd_send_cmd(0,0,0x4A);
  sd_get_resp();           // ignore response if there is any

  // the second CMD0, expecting idle status
  sd_send_cmd(0,0,0x4A);
  regValue = sd_get_resp();
  if(regValue != 0x01)
    return regValue | 0x100000000;

  return 0;
}

uint64_t sd_send_cmd(uint8_t cmd, uint32_t arg, uint8_t crc7) {
  *(spi_base_ptr + SPI_DTR) = (0x1 << 14) | ((cmd & 0x3F) << 8) | (arg >> 24);
  *(spi_base_ptr + SPI_DTR) = (arg >> 8);
  *(spi_base_ptr + SPI_DTR) = (arg << 8) | ((crc7 & 0x7F) << 1) | 0x1;
  spi_dump_recv();
  return 0;
}

uint64_t sd_get_resp() {
  int i;
  uint64_t rv = 0;
  for(i=0; i<4; i++)
    *(spi_base_ptr + SPI_DTR) = 0xFFFF;
  // wait transmit finish
  while(GetBit(*(spi_base_ptr + SPI_SR), 2));
  for(i=0; i<4; i++)
    rv = (rv << 16) | (*(spi_base_ptr + SPI_DRR) & 0xFFFF);

  return rv;
}

void spi_boot() {
  int i;
  // send 128 (>= 74) dummy clock to SD
  for(i=0; i<8; i++)
    *(spi_base_ptr + SPI_DTR) = 0xFFFF;

  spi_dump_recv();
}

void spi_slave_enable () {
  *(spi_base_ptr + SPI_SSR) = 0xFFFFFFFE;
}

void spi_slave_disable () {
  *(spi_base_ptr + SPI_SSR) = 0xFFFFFFFF;
}

void spi_dump_recv() {
  // wait until data transmitted
  while(GetBit(*(spi_base_ptr + SPI_SR), 2));
  // reset recv FIFO
  *(spi_base_ptr + SPI_CR) = 0xC6;
}
