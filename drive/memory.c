#include "memory.h"

volatile uint32_t * get_ddr_base() {
  return (uint32_t *)(DDR_RAM_BASE);
}
