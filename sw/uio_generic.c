/*
 * This code has been created with the help of what Benjamin James
 * Already coded available on his Github : 
 * https://github.com/byu-cpe/ecen427_student/tree/master/userspace/drivers/uio_example
 */

#include "uio_generic.h"
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

off_t offset = 0x0;         // Already pagevo  aligned
size_t length = 0x00001000; // Length of the component

// Generate the UIO Device file
uint32_t * generic_init(char devDevice[]) {
  int uiofd = open(devDevice, O_RDWR);
  if (uiofd < 0) {
      handle_error("uio open:");
      return NULL;
    }

  uint32_t * addr = mmap(NULL, length, PROT_READ|PROT_WRITE, MAP_SHARED, uiofd, offset);
  if (addr == MAP_FAILED) {
      handle_error("mmap");
      return NULL;
  }

  return addr;

}

// Device init
int device_init(char devDevice[]) {
  int uiofd = open(devDevice, O_RDWR);
    if (uiofd < 0) {
        handle_error("uio open:");
        return NULL;
      }
  return uiofd;
}

uint32_t * addr_init(int uiofd) {
  uint32_t * addr = mmap(NULL, length, PROT_READ|PROT_WRITE, MAP_SHARED, uiofd, offset);
    if (addr == MAP_FAILED) {
        handle_error("mmap");
        return NULL;
    }
    return addr;
}


// Write to a register of the UIO device
void generic_write(uint32_t offset, uint32_t value, uint32_t * addr) {
  *((volatile uint32_t *)(addr + offset)) = value;
}

// Read from a register of the UIO device
uint32_t generic_read(uint32_t offset, uint32_t * addr) {
  return *((volatile uint32_t *)(addr + offset));
}


// Close uio device
void generic_exit(uint32_t * addr) {
  munmap(addr, length);
}