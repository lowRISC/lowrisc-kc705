// See LICENSE for license details.

#include "memory.h"

volatile uint64_t * get_ddr_base() {
  return (uint64_t *)(DDR_RAM_BASE);
}
