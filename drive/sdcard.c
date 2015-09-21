
#include "sdcard.h"

volatile uint32_t *spi_base_ptr = (uint32_t *)(SPI_BASE);

void spi_dump_recv();
void spi_boot_cycles();

uint32_t sd_init() {
  uint32_t resp;

  // software reset?
  *(spi_base_ptr + SPI_SRR) = 0xa;

  // set control register
  // MSB first, master, reset FIFOs, SPI disabled, clock 00 mode
  *(spi_base_ptr + SPI_CR) = 0xE4;
  
  // disable interrupt, full polling mode
  *(spi_base_ptr + SPI_GIER) = 0x0;

  // read status register
  resp = (*(spi_base_ptr + SPI_SR)) & 0x7FF;
  if(resp != 0x25)
    return SD_ERR_SPI; // SPI error!

  // enable spi
  *(spi_base_ptr + SPI_CR) = 0x86;

  // give clocks to slave for it to boot
  spi_boot_cycles();

  ////////////
  // initialize the card
  uint32_t card_type;

  // select the card
  spi_slave_enable();

  // card reset to SPI mode
  sd_send_cmd(0,0,0x4A); // CMD0
  resp = sd_send_cmd(0,0,0x4A); // CMD0
  if(resp != 0x01)
    return SD_ERR_RST; // card reset error

  // CMD8 check for SD V2
  resp = sd_send_cmd(8,0x01AA, 0x43);
  if(GetBit(resp, 2)) {
    // timeout or illegal command, non-SDV2 card
    sd_send_cmd(55,0, 0); // ACMD prefix
    resp = sd_send_cmd(41,0x40000000, 0); // ACMD41
    if(GetBit(resp, 2)) // timeout or illegal command
      card_type = SD_TYPE_MMC;  // MMC card
    else
      card_type = SD_TYPE_SD_V1;  // SD V1 card
  } else if((resp & 0xFFF) == 0x01AA) {
    card_type = SD_TYPE_SD_V2; // SD V2 card
  } else {
    return SD_ERR_VOLTAGE; // uncompatible voltage
  }

  // initialize the SD card
  uint32_t cmd_cnt = 0;
  do{
    cmd_cnt++;
    switch(card_type) {
    case SD_TYPE_MMC: { // MMC card
      resp = sd_send_cmd(1,0x40000000, 0); // CMD1
      break;
    }
    case SD_TYPE_SD_V1: { // SD V1 card
      sd_send_cmd(55,0, 0); // ACMD prefix
      resp = sd_send_cmd(41,0x00000000, 0); // ACMD41
      break;
    }
    default: { // SD V2 or SDHC
      sd_send_cmd(55,0, 0); // ACMD prefix
      resp = sd_send_cmd(41,0x40000000, 0); // ACMD41
      break;
    }
    }
  } while(resp != 0 && cmd_cnt < SD_INIT_MAX_CYCLE);

  // check for timeout
  if(cmd_cnt == SD_INIT_MAX_CYCLE)
    return SD_ERR_TIMEOUT; // timeout in init

  // check for SD HC
  if(card_type == SD_TYPE_SD_V2) { // check whether HC
    resp = sd_send_cmd(58, 0, 0); // CMD41
    if(GetBit(resp, 30)) card_type = SD_TYPE_SD_HC; // SDHC
  }

  // set Block size to 512 bytes
  if(card_type != SD_TYPE_SD_HC) {
    resp = sd_send_cmd(16, 0x200, 0); // CMD16
  }

  return card_type;
}

uint32_t sd_send_cmd(uint8_t cmd, uint32_t arg, uint8_t crc7) {
  int i;
  unsigned char resp[16];

  // send command
  *(spi_base_ptr + SPI_DTR) = (0x1 << 14) | ((cmd & 0x3F) << 8) | (arg >> 24);
  *(spi_base_ptr + SPI_DTR) = (arg >> 8);
  *(spi_base_ptr + SPI_DTR) = (arg << 8) | ((crc7 & 0x7F) << 1) | 0x1;
  spi_dump_recv();

  // get resp
  for(i=0; i<8; i++) *(spi_base_ptr + SPI_DTR) = 0xFFFF; // send clocks
  while(!GetBit(*(spi_base_ptr + SPI_SR), 2));           // wait transmitting
  for(i=0; i<8; i++) {
    uint16_t m = *(spi_base_ptr + SPI_DRR) & 0xFFFF;
    resp[i*2] = m >> 8;
    resp[i*2+1] = m & 0xff;
  }

  // analyse response
  switch(cmd) {
  case 8:
  case 58: { // CMD 8, 58, R3, R7
    for(i=0; i<16; i++) {
      if(resp[i] != 0xFF) {
        // find response
        if((resp[i] & 0xFE) != 0x00) return resp[i]; // command error
        return
          ((uint64_t)(resp[i+1]&0xFF) << 24) |
          ((uint64_t)(resp[i+2]&0xFF) << 16) |
          ((uint64_t)(resp[i+3]&0xFF) << 8)  |
          ((uint64_t)(resp[i+4]&0xFF))       ;
      }
    }
    return 0xFF;
  }
  default: {
    for(i=0; i<16; i++)
      if(resp[i] != 0xFF)
        return resp[i];
  }
  }
  return 0xFF;
}

void spi_slave_enable () {
  *(spi_base_ptr + SPI_SSR) = 0xFFFFFFFE;
}

void spi_slave_disable () {
  *(spi_base_ptr + SPI_SSR) = 0xFFFFFFFF;
}

void spi_dump_recv() {
  // wait until data transmitted
  while(!GetBit(*(spi_base_ptr + SPI_SR), 2));
  // reset recv FIFO
  *(spi_base_ptr + SPI_CR) = 0xC6;
}

void spi_boot_cycles() {
  int i;
  // send 128 (>= 74) dummy clock to SD
  for(i=0; i<8; i++)
    *(spi_base_ptr + SPI_DTR) = 0xFFFF;

  spi_dump_recv();
}

