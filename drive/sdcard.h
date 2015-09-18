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
extern int sd_init();

// send SD command (using SPI mode)
extern uint64_t sd_send_cmd(uint8_t cmd, uint32_t arg, uint8_t crc7);

// get response
extern uint64_t sd_get_resp();

// give slave enough clock to boot
extern void spi_boot();

// enable slave communication (cs -> low)
extern void spi_slave_enable();

// disable slave communication (cs -> high)
extern void spi_slave_disable();

// dump recv
extern void spi_dump_recv();

#endif
