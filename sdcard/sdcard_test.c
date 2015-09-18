// SD test program

#include <stdio.h>
#include "sdcard.h"
#include "uart.h"

int main() {
  uint64_t resp;

  uart_init();
  sd_init();

  printf("boot\n", resp);
  sd_send_cmd(0,0,0x4A); // CMD0
  printf("CMD0\n", resp);
  resp = sd_get_resp();
  printf("%llx\n", resp);
  resp = sd_get_resp();
  printf("%llx\n", resp);

  sd_send_cmd(0,0,0x4A); // CMD0
  printf("CMD0\n", resp);
  resp = sd_get_resp();
  printf("%llx\n", resp);

  resp = sd_get_resp();
  printf("%llx\n", resp);

  return 0;
}
