#include "uio_generic.h"
#include <stdint.h>
#include <stdio.h>
//#include <time.h>
//#include <signal.h>


int main(int argc, char* argv[])
{
	// De-Configure printf buffer to log to file without
	setbuf(stdout, NULL);
	//Create time logger
	//char buff[20];
    //struct tm *sTm;

	// EXP CONFIG
	uint32_t N_READS = 1;
	uint32_t T_WRITE = 1;
	uint32_t T_WRITE_RESOLUTION = 1;
	
	// Get config from args
	for(int i = 0; i < argc; i++){
        //printf("\nArgument %d = argv[%d] = %s\n", i , i, argv[i]);
		if (i == 1) {
			N_READS = (uint32_t)strtoul(argv[i], NULL, 0);
		} else if (i == 2)		{
			T_WRITE = (uint32_t)strtoul(argv[i], NULL, 0);
		} else if (i == 3)		{ 	
			T_WRITE_RESOLUTION = (uint32_t)strtoul(argv[i], NULL, 0);
		}
		
    }

	//uint32_t * addr;
	//addr = generic_init("/dev/uio1");
	int uiofd = device_init("/dev/uio3");
	uint32_t * addr = addr_init(uiofd);

	printf("START\n");
	uint32_t n_reads = generic_read(1, addr);
	uint32_t t_write = generic_read(2, addr);
	uint32_t t_write_resolution = generic_read(3, addr);
	uint32_t on_off = generic_read(0, addr);
	printf("preCONFIG:\n Number of reads per write: %d\n Time between writes: %d\n Resolution mode: %d\n Hardware Activation: %d\n", n_reads, t_write, t_write_resolution, on_off);

	// CONFIGURE and START HW
	generic_write(1, N_READS, addr); // n_reads
	generic_write(2, T_WRITE, addr); // t_write = 1 seconds
	generic_write(3, T_WRITE_RESOLUTION, addr); // t_write_resolution = 1 to have it in seconds
	generic_write(0, 1, addr); // Start Experiment


	n_reads = generic_read(1, addr);
	t_write = generic_read(2, addr);
	t_write_resolution = generic_read(3, addr);
	on_off = generic_read(0, addr);
	printf("postCONFIG:\n Number of reads per write: %d\n Time between writes: %d\n Resolution mode: %d\n Hardware Activation: %d\n", n_reads, t_write, t_write_resolution, on_off);
	const char *resolution = t_write_resolution == 1 ? "s" : "ms";
	printf("Reading every %d %s. Writting every: %d %s.\n", (t_write/n_reads), resolution, t_write, resolution);



	uint32_t test = generic_read(4, addr);
	printf("Test Events at START: %d\n", test);
	//time_t now = time (0);
	//sTm = gmtime (&now);
	//strftime (buff, sizeof(buff), "%Y-%m-%d %H:%M:%S", sTm);
	//printf ("%s %s\n", buff, "Initial Time");

	generic_exit(addr); // Close device

	while(1){
		//sleep(100);
		uint32_t info = 1; /* unmask */
		ssize_t nb = write(uiofd, &info, sizeof(info));

		nb = read(uiofd, &info, sizeof(info));
        if (nb >= (ssize_t)sizeof(info)) {
			//Open device
			uint32_t * addr = addr_init(uiofd);

            /* Do something in response to the interrupt. */
            //printf("Interrupt #%u!\n", info);
			uint32_t bitflips = generic_read(4, addr);
			//printf("Interrupt trigger, number of bitfips: %d\n", bitflips);

			generic_exit(addr); // Close device

			//time_t now = time (0);
			//sTm = gmtime (&now);
			//strftime (buff, sizeof(buff), "%Y-%m-%d %H:%M:%S", sTm);
			//printf ("%s %s %d\n", buff, "Events occurred:", bitflips);
			printf ("%s %d\n", "Events:", bitflips);
        }


	}
	printf("END\n");
}