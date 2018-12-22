#include <stdio.h>
#include <stdlib.h>
#include <pcap.h>

/**
 * Display meaningfull information on how to use this program
 */
void usage (char *argv[]) {

	fprintf (stdout, "Usage: %s <file.pcap>\n", argv[0]);
};

int main (int argc, char *argv[]) {

	// Check arguments integrity
	if (argc < 2) {

		usage (argv);
		exit (EXIT_FAILURE);
	}

	// Loading pcap file
	char error_buffer[PCAP_ERRBUF_SIZE];
	pcap_t *handle = pcap_open_offline(argv[1], error_buffer);

	if (handle == NULL) {

		printf("Error with the file: %s [%s]\n", argv[1], error_buffer);
		exit (EXIT_FAILURE);
	}

	// a suivre
    pcap_close (handle);

	exit (EXIT_SUCCESS);
}

