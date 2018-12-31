#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <pcap.h>
#include <netinet/in.h>
#include <netinet/if_ether.h>
#include <stdarg.h>

/*
#include "types.h"
#include "pop.tab.h"

// typedef size_t yy_size_t;
// 
// extern YY_BUFFER_STATE yy_scan_buffer ( char *base, yy_size_t size  );

extern void scan_string(const char*);

Command_list* parse(const char* str) {
    extern Command_list* list_of_commands___;
    scan_string(str);
    yyparse();
    return list_of_commands___;
}
*/

typedef struct client_requests {

	char *data;
	struct client_requests *next;

} t_client_requests, *p_client_requests;

p_client_requests create_client_requests (char *data) {

	p_client_requests pcr = malloc (sizeof (t_client_requests));

	if (pcr == NULL) {

		perror ("[ERROR] Can't create a new client request queue");
		exit (EXIT_FAILURE);
	}

	pcr->data = data;
	pcr->next = NULL;

	return pcr;
}

char *pop_client_requests (p_client_requests *pcr) {

	char *data;

	if ((*pcr)->data == NULL)
		return NULL;

	data = (*pcr)->data;

	if ((*pcr)->next == NULL)
		(*pcr)->data = NULL;
	else
		*pcr = (*pcr)->next;
	
	return data;
}

void push_client_requests (p_client_requests pcr, char *data) {

	while (pcr->data != NULL && pcr->next != NULL)
		pcr = (p_client_requests) pcr->next;

	if (pcr->data == NULL) {

		pcr->data = data;
		return;

	} else
		pcr->next = (struct client_requests *) create_client_requests (data);

	return;
}

void debug_client_requests (p_client_requests pcr) {

	fprintf (stdout, "------- START -------\n");

	while (pcr->data != NULL && pcr->next != NULL) {

		fprintf (stdout, "%s\n", pcr->data);
		pcr = (p_client_requests) pcr->next;
	}

	if (pcr->data != NULL)
		fprintf (stdout, "%s\n", pcr->data);

	fprintf (stdout, "------- END -------\n");
}

/**
 * Display meaningfull information on how to use this program
 */
void usage (char *argv[]) {

	fprintf (stdout, "Usage: %s <file.pcap>\n", argv[0]);
}

/* Finds the payload of a TCP/IP packet */
void my_packet_handler(u_char *args, const struct pcap_pkthdr *header, const u_char *packet) {

	/* First, lets make sure we have an IP packet */
	struct ether_header *eth_header;
	eth_header = (struct ether_header *) packet;
	if (ntohs(eth_header->ether_type) != ETHERTYPE_IP) {
		//printf("Not an IP packet. Skipping...\n\n");
		return;
	}

	/* The total packet length, including all headers
	   and the data payload is stored in
	   header->len and header->caplen. Caplen is
	   the amount actually available, and len is the
	   total packet length even if it is larger
	   than what we currently have captured. If the snapshot
	   length set with pcap_open_live() is too small, you may
	   not have the whole packet. */
	//printf("Total packet available: %d bytes\n", header->caplen);
	//printf("Expected packet size: %d bytes\n", header->len);

	/* Pointers to start point of various headers */
	const u_char *ip_header;
	const u_char *tcp_header;
	const u_char *payload;

	/* Header lengths in bytes */
	int ethernet_header_length = 14; /* Doesn't change */
	int ip_header_length;
	int tcp_header_length;
	int payload_length;

	/* Find start of IP header */
	ip_header = packet + ethernet_header_length;
	/* The second-half of the first byte in ip_header
	   contains the IP header length (IHL). */
	ip_header_length = ((*ip_header) & 0x0F);
	/* The IHL is number of 32-bit segments. Multiply
	   by four to get a byte count for pointer arithmetic */
	ip_header_length = ip_header_length * 4;
	//printf("IP header length (IHL) in bytes: %d\n", ip_header_length);

	/* Now that we know where the IP header is, we can 
	   inspect the IP header for a protocol number to 
	   make sure it is TCP before going any further. 
	   Protocol is always the 10th byte of the IP header */
	u_char protocol = *(ip_header + 9);
	if (protocol != IPPROTO_TCP) {
		//printf("Not a TCP packet. Skipping...\n\n");
		return;
	}

	/* Add the ethernet and ip header length to the start of the packet
	   to find the beginning of the TCP header */
	tcp_header = packet + ethernet_header_length + ip_header_length;
	/* TCP header length is stored in the first half 
	   of the 12th byte in the TCP header. Because we only want
	   the value of the top half of the byte, we have to shift it
	   down to the bottom half otherwise it is using the most 
	   significant bits instead of the least significant bits */
	tcp_header_length = ((*(tcp_header + 12)) & 0xF0) >> 4;
	/* The TCP header length stored in those 4 bits represents
	   how many 32-bit words there are in the header, just like
	   the IP header length. We multiply by four again to get a
	   byte count. */
	tcp_header_length = tcp_header_length * 4;
	//printf("TCP header length in bytes: %d\n", tcp_header_length);

	/* Add up all the header sizes to find the payload offset */
	int total_headers_size = ethernet_header_length+ip_header_length+tcp_header_length;
	//printf("Size of all headers combined: %d bytes\n", total_headers_size);
	payload_length = header->caplen -
		(ethernet_header_length + ip_header_length + tcp_header_length);
	//printf("Payload size: %d bytes\n", payload_length);
	payload = packet + total_headers_size;
	//printf("Memory address where payload begins: %p\n\n", payload);

	/* Store the payload */
	if (payload_length > 0) {

		size_t raw_length = sizeof (u_char) * (payload_length + 1);
		char *data = malloc (raw_length);
		if (data == NULL) {

			perror ("[ERROR] Can't allocate the payload");
			exit (EXIT_FAILURE);
		}

		memcpy (data, payload, raw_length);
		data[payload_length] = '\0';
        /*
        for (int j = 0 ; j <= payload_length ; j++)
            fprintf (stdout, " 0x%x", data[j]);
        */
		fprintf (stdout, "\n<<%s>>\n", data);
        parser (data, payload_length);

		free (data);
	}

	return;
}

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

		printf("[ERROR] Can't read the file: %s [%s]\n", argv[1], error_buffer);
		exit (EXIT_FAILURE);
	}

	// Loop and extract the pop3 payload
  	u_char *my_arguments = NULL;

	struct bpf_program fp;
	pcap_compile(handle, &fp, "tcp", 0, PCAP_NETMASK_UNKNOWN);
	pcap_setfilter(handle, &fp);
	pcap_loop(handle, -1, my_packet_handler, my_arguments);

	// Free memory
	pcap_close (handle);


	// Debug fifo implementation
	p_client_requests list = create_client_requests (NULL);
	debug_client_requests (list);
	list = create_client_requests ("toto");
	debug_client_requests (list);
	push_client_requests (list, "titi");
	push_client_requests (list, "tutu");
	push_client_requests (list, "tata");
	debug_client_requests (list);
	fprintf (stdout, "POP -> %s\n", pop_client_requests (&list));
	debug_client_requests (list);
	fprintf (stdout, "POP -> %s\n", pop_client_requests (&list));
	fprintf (stdout, "POP -> %s\n", pop_client_requests (&list));
	debug_client_requests (list);
	push_client_requests (list, "titi");
	push_client_requests (list, "titi");
	push_client_requests (list, "titi");
	push_client_requests (list, "titi");
	debug_client_requests (list);
	fprintf (stdout, "POP -> %s\n", pop_client_requests (&list));
	fprintf (stdout, "POP -> %s\n", pop_client_requests (&list));
	debug_client_requests (list);
	fprintf (stdout, "POP -> %s\n", pop_client_requests (&list));
	fprintf (stdout, "POP -> %s\n", pop_client_requests (&list));
	fprintf (stdout, "POP -> %s\n", pop_client_requests (&list));
	debug_client_requests (list);
	fprintf (stdout, "POP -> %s\n", pop_client_requests (&list));
	debug_client_requests (list);

	exit (EXIT_SUCCESS);
}

