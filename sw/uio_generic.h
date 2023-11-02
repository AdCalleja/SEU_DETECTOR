/*
 * This code has been created with the help of what Benjamin James
 * Already coded available on his Github : 
 * https://github.com/byu-cpe/ecen427_student/tree/master/userspace/drivers/uio_example
 */

#include <stdint.h>
#include <sys/mman.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#define handle_error(msg) do { perror(msg); exit(EXIT_FAILURE); } while (0)

uint32_t * generic_init(char devDevice[]);
int device_init(char devDevice[]);
uint32_t * addr_init(int uiofd);
void generic_write(uint32_t offset, uint32_t value, uint32_t * addr);
uint32_t generic_read(uint32_t offset, uint32_t * addr);
void generic_exit();