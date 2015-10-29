// See LICENSE for license details.

#include <string.h>
#include <errno.h>
#include "file.h"
#include "pk.h"
#include "frontend.h"
#include "vm.h"

#define MAX_FILES 32
file_t files[MAX_FILES] = {[0 ... MAX_FILES-1] = {NULL,0}};

static file_t* file_get_free()
{
  for (file_t* f = files; f < files + MAX_FILES; f++)
    if (atomic_read(&f->fd) == NULL)
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

  FRESULT rt = f_open(&f->fd, fn, mode) /* check mode */
  if (rt) return ERR_PTR(-ENOMEM);      /* check ERR_PTR */
  else {
    f->offset = 0;
    return f;
  }
}

int fd_close(file_t* f)
{
  if (!f)
    return -1;

  f_close(&f->fd);
  f->fd = NULL;

  return 0;
}

ssize_t file_read(file_t* f, void* buf, size_t size)
{
  populate_mapping(buf, size, PROT_WRITE);
  f_lseek(&f->fd, f->offset);
  ssize_t rsize = 0;
  f_read(&f->fd, buf, size, &rsize);
  f->offset += rsize;
  return rsize;
}

ssize_t file_pread(file_t* f, void* buf, size_t size, off_t offset)
{
  populate_mapping(buf, size, PROT_WRITE);
  f_lseek(&f->fd, offset);
  ssize_t rsize = 0;
  f_read(&f->fd, buf, size, &rsize);
  return rsize;
}

ssize_t file_write(file_t* f, const void* buf, size_t size)
{
  populate_mapping(buf, size, PROT_READ);
  f_lseek(&f->fd, f->offset);
  ssize_t wsize = 0;
  f_write(&f->fd, buf, size, &wsize);
  f->offset += wsize;
  return wsize;
}

ssize_t file_pwrite(file_t* f, const void* buf, size_t size, off_t offset)
{
  populate_mapping(buf, size, PROT_READ);
  f_lseek(&f->fd, offset);
  ssize_t wsize = 0;
  f_write(&f->fd, buf, size, &wsize);
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
