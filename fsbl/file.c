// See LICENSE for license details.

#include <string.h>
#include <errno.h>
#include "file.h"
#include "fsbl.h"
#include "vm.h"
#include "driver/ff.h"

#define MAX_FILES 32
file_t files[MAX_FILES] = {[0 ... MAX_FILES-1] = {NULL,0,0}};
spinlock_t file_lock = SPINLOCK_INIT;
spinlock_t refcnt_lock = SPINLOCK_INIT;

void file_incref(file_t* f)
{
  long flags = spinlock_lock_irqsave(&refcnt_lock);
  long prev = f->refcnt;
  f->refcnt = prev + 1;
  spinlock_unlock_irqrestore(&refcnt_lock,flags);
  kassert(prev > 0);
}

void file_decref(file_t* f)
{
  long flags = spinlock_lock_irqsave(&refcnt_lock);
  long prev = f->refcnt;
  f->refcnt = prev - 1;
  if (prev == 2)
  {
    f->refcnt = 0;
    f_close(&f->fd);
    f->fd = NULL;
  }
  spinlock_unlock_irqrestore(&refcnt_lock,flags);
}

static file_t* file_get_free()
{
  for (file_t* f = files; f < files + MAX_FILES; f++)
    if (atomic_read(&f->fd) == NULL && atomic_cas(&f->refcnt, 0, 2) == 0)
      return f;
  return NULL;
}

void file_init()
{
}

file_t* file_open(const char* fn, int flags, int mode)
{
  return file_openat(AT_FDCWD, fn, flags, mode);
}

file_t* file_openat(int dirfd, const char* fn, int flags, int mode)
{
  file_t* f = file_get_free();
  if (f == NULL)
    return ERR_PTR(-ENOMEM);

  FRESULT rt = f_open(&f->fd, fn, mode); /* check mode */
  if (rt) {
    file_decref(f);
    return ERR_PTR(-ENOMEM);      /* check ERR_PTR */
  } else {
    f->offset = 0;
    return f;
  }
}

ssize_t file_read(file_t* f, void* buf, size_t size)
{
  populate_mapping(buf, size, PROT_WRITE);
  long flags = spinlock_lock_irqsave(&file_lock);
  f_lseek(&f->fd, f->offset);
  ssize_t rsize = 0;
  f_read(&f->fd, buf, size, &rsize);
  f->offset += rsize;
  spinlock_unlock_irqrestore(&file_lock,flags);
  return rsize;
}

ssize_t file_pread(file_t* f, void* buf, size_t size, off_t offset)
{
  populate_mapping(buf, size, PROT_WRITE);
  long flags = spinlock_lock_irqsave(&file_lock);
  f_lseek(&f->fd, offset);
  ssize_t rsize = 0;
  f_read(&f->fd, buf, size, &rsize);
  spinlock_unlock_irqrestore(&file_lock,flags);
  return rsize;
}

ssize_t file_write(file_t* f, const void* buf, size_t size)
{
  populate_mapping(buf, size, PROT_READ);
  long flags = spinlock_lock_irqsave(&file_lock);
  f_lseek(&f->fd, f->offset);
  ssize_t wsize = 0;
  f_write(&f->fd, buf, size, &wsize);
  f->offset += wsize;
  spinlock_unlock_irqrestore(&file_lock,flags);
  return wsize;
}

ssize_t file_pwrite(file_t* f, const void* buf, size_t size, off_t offset)
{
  populate_mapping(buf, size, PROT_READ);
  long flags = spinlock_lock_irqsave(&file_lock);
  f_lseek(&f->fd, offset);
  ssize_t wsize = 0;
  f_write(&f->fd, buf, size, &wsize);
  spinlock_unlock_irqrestore(&file_lock,flags);
  return wsize;
}

int file_stat(const char* fn, struct stat* s)
{
  populate_mapping(s, sizeof(*s), PROT_WRITE);
  FRESULT rt = f_stat(fn, s);   /* check struct of stat */
  if(rt) return -1;
  else return 0;
}

int file_truncate(file_t* f, off_t len)
{
  panic("file_truncate() not supported!");
  return -1;
}

ssize_t file_lseek(file_t* f, size_t ptr, int dir)
{
  FRESULT rt;
  if(dir == SEEK_SET) {
    rt = f_lseek(&f->fd, ptr);
    if(rt) return -1;
    else return ptr;
  } else if(dir == SEEK_CUR) {
    rt = f_lseek(&f->fd, f->offset + ptr);
    if(rt) return -1;
    else return f->offset + ptr;
  } else {
    panic("lseek SEEK_END not supported!");
    return -1;
  }
}
