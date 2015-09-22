// SD test program

#include <stdio.h>
#include "diskio.h"
#include "ff.h"
#include "uart.h"

int main() {
  DSTATUS s;

  uart_init();
  s = disk_initialize(0);

  printf("disk status = %0x\n", s);

  return 0;
}
