#ifndef DEVICE_MAP_H
#define DEVICE_MAP_H

// DDR RAM
#define DDR_RAM_BASE 0x40000000u

// IO Space
#define IO_SPACE_BASE 0x80000000u

#define REG_ADDR(base, offset) (base + offset)

#endif
