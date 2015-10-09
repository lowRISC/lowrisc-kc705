
#include <stdint.h>
#include "device_map.h"

volatile uint64_t *memory_record = (uint64_t *)(IO_SPACE_BASE);
volatile uint64_t *memory_orig_base = (uint64_t *)(0x00000);
volatile uint64_t *memory_copy_base = (uint64_t *)(0x4000);
extern long syscall(long num, long arg0, long arg1, long arg2);

int main() {

  syscall(1226, IO_SPACE_BASE, IO_SPACE_BASE-1, 0);

  uint64_t offset = 0;
  for(; offset < 0x4000/8; offset++)
    *(memory_copy_base + offset) = *(memory_orig_base + offset);

  if(*(memory_record) == 0x10000)
    return 0;
  else {
    *(memory_record) += 0x4000;
    syscall(210, 0, IO_SPACE_BASE-1, *(memory_record));
    syscall(617, 0, 0, 0);
  }
  return 1;
}
