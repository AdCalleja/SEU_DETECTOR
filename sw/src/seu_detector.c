#include "uio_generic.h"
#include <stdint.h>

int main()
{
	//uint32_t * addr;
	//addr = generic_init("/dev/uio1");
	int uiofd = device_init("/dev/uio1");
	uint32_t * addr = addr_init(uiofd);

	printf("START\n");
	uint32_t n_reads = generic_read(1, addr);
	uint32_t t_write = generic_read(2, addr);
	uint32_t t_write_resolution = generic_read(3, addr);
	uint32_t on_off = generic_read(0, addr);
	printf("CONFIG PRE:\n nreads = %d\n t_write = %d\n t_write_resolution = %d\n on_off = %d\n", n_reads, t_write, t_write_resolution, on_off);

	generic_write(1, 1, addr); // n_reads
	generic_write(2, 1, addr); // t_write = 1 seconds
	generic_write(3, 1, addr); // t_write_resolution = 1 to have it in seconds
	generic_write(0, 1, addr); // Start Experiment


	n_reads = generic_read(1, addr);
	t_write = generic_read(2, addr);
	t_write_resolution = generic_read(3, addr);
	on_off = generic_read(0, addr);
	printf("CONFIG:\n nreads = %d\n t_write = %d\n t_write_resolution = %d\n on_off = %d\n", n_reads, t_write, t_write_resolution, on_off);



	uint32_t test = generic_read(4, addr);
	printf("Test0 number of bitfips pre: %d\n", test);

	while(1){
		//sleep(100);
		uint32_t info = 1; /* unmask */
		ssize_t nb = write(uiofd, &info, sizeof(info));
		printf("Looping again");

		nb = read(uiofd, &info, sizeof(info));
		printf("Info Value: %d\n", info);
		printf("Sizeof int: %d\n", sizeof(info));
        if (nb >= (ssize_t)sizeof(info)) {
            /* Do something in response to the interrupt. */
            printf("Interrupt #%u!\n", info);
			uint32_t bitflips = generic_read(4, addr);
			printf("Interrupt trigger, number of bitfips: %d\n", bitflips);
        }


	}
	printf("END\n");
	generic_exit(addr);
}