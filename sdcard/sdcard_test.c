// SD test program

#include <stdio.h>
#include "sdcard.h"
#include "uart.h"

int main() {
  uint32_t card_type;

  uart_init();
  card_type = sd_init();

  printf("sd card type = %0x\n", card_type);

  return 0;
}
