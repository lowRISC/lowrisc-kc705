// See LICENSE for license details.

#include "pk.h"
#include "atomic.h"
#include "frontend.h"
#include "sbi.h"
#include "mcall.h"
#include "syscall.h"
#include <stdint.h>

void die(int code)
{
  while (1);
}
