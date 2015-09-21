#ifndef SD_CARD_HEADER_H
#define SD_CARD_HEADER_H

#include <stdint.h>
#include "device_map.h"

// Xilinx AXI_QUAD_SPI

#define SPI_BASE (IO_SPACE_BASE + 0x10000u)

// Global interrupt enable register [Write]
#define SPI_GIER 0x07u

// IP interrupt status register [Read/Toggle to write]
#define SPI_ISR 0x08u

// IP interrupt enable register [Read/Write]
#define SPI_IER 0x0Au

// Software reset register [Write]
#define SPI_SRR 0x10u

// SPI control register [Read/Write]
#define SPI_CR 0x18u

// SPI status register [Read]
#define SPI_SR 0x19u

// SPI data transmit register, FIFO-16 [Write]
#define SPI_DTR 0x1Au

// SPI data receive register, FIFO-16 [Read]
#define SPI_DRR 0x1Bu

// SPI Slave select register, [Read/Write]
#define SPI_SSR 0x1Cu

// Transmit FIFO occupancy register [Read]
#define SPI_TFOR 0x1Du

// Receive FIFO occupancy register [Read]
#define SPI_RFROR 0x1Eu

// SPI APIs

// initialize SD card
extern uint32_t sd_init();

// Define init return value
#define SD_TYPE_MMC    0
#define SD_TYPE_SD_V1  1
#define SD_TYPE_SD_V2  2
#define SD_TYPE_SD_HC  3

#define SD_ERR_SPI      0x100
#define SD_ERR_RST      0x101
#define SD_ERR_VOLTAGE  0x102
#define SD_ERR_TIMEOUT  0x103

// wait for maximal 500ms for SD to initialize
#define SD_INIT_MAX_CYCLE 250000

// send SD command (using SPI mode)
extern uint32_t sd_send_cmd(uint8_t cmd, uint32_t arg, uint8_t crc7);

// enable slave communication (cs -> low)
extern void spi_slave_enable();

// disable slave communication (cs -> high)
extern void spi_slave_disable();

#endif
