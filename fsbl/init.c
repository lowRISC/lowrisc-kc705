// See LICENSE for license details.

#include "fsbl.h"
#include "vm.h"
#include "elf.h"
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

elf_info current;
int have_vm = 1;

int uarch_counters_enabled;
long uarch_counters[NUM_COUNTERS];
char* uarch_counter_names[NUM_COUNTERS];

void init_tf(trapframe_t* tf, long pc, long sp, int user64)
{
  memset(tf, 0, sizeof(*tf));
  if (!user64)
    panic("can't run 32-bit ELF on 64-bit pk");
  tf->status = read_csr(sstatus);
  tf->gpr[2] = sp;
  tf->epc = pc;
}

void boot_loader()
{
  // set memory size
  uintptr_t mem_mb = 1024;      /* 1GB DDR3 */
  mem_size = mem_mb << 20;
  if ((mem_size >> 20) < mem_mb)
    mem_size = (typeof(mem_size))-1 & -RISCV_PGSIZE;

  // load program named "boot"
  long phdrs[128];
  current.phdr = (uintptr_t)phdrs;
  current.phdr_size = sizeof(phdrs);
  load_elf("boot", &current);

  run_loaded_program();
}
