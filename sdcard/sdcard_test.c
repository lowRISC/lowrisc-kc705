// SD test program

#include <stdio.h>
#include "diskio.h"
#include "ff.h"
#include "uart.h"

/* Read a text file and display it */

FATFS FatFs;   /* Work area (file system object) for logical drive */

int main (void)
{
  FIL fil;                /* File object */
  uint8_t buffer[64];     /* File copy buffer */
  FRESULT fr;             /* FatFs return code */
  uint32_t br;            /* Read count */
  uint32_t i;

  uart_init();

  /* Register work area to the default drive */
  f_mount(&FatFs, "", 0);

  /* Open a text file */
  fr = f_open(&fil, "test.txt", FA_READ);
  if (fr) {
    printf("failed to open test.text!\n");
    return (int)fr;
  } else {
    printf("test.txt opened\n");
  }

  /* Read all lines and display it */
  for (;;) {
    fr = f_read(&fil, buffer, sizeof(buffer), &br);  /* Read a chunk of source file */
    if (fr || br == 0) break; /* error or eof */
    printf("%s", buffer);
  }

  /* Close the file */
  f_close(&fil);
  printf("test.txt closed\n");

  return 0;
}
