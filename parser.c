#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>

void parser (char *data, int len) {

    char *ret;
    if ((ret = strstr (data, "+OK")) != NULL) {

        fprintf (stdout, ">>%s\n", data);

    } else if ((ret = strstr (data, "-ERR")) != NULL) {

    // Basic command
    } else if ((ret = strstr (data, "DELE ")) != NULL) {

    } else if ((ret = strstr (data, "LIST\r\n")) != NULL) {

    } else if ((ret = strstr (data, "RETR ")) != NULL) {

    } else if ((ret = strstr (data, "TOP ")) != NULL) {

    } else if ((ret = strstr (data, "STAT\r\n")) != NULL) {

    // Misc command
    } else if ((ret = strstr (data, "APOP\r\n")) != NULL) {

    } else if ((ret = strstr (data, "NOOP\r\n")) != NULL) {

    } else if ((ret = strstr (data, "QUIT\r\n")) != NULL) {

    } else if ((ret = strstr (data, "RSET\r\n")) != NULL) {

    } else if ((ret = strstr (data, "UIDL\r\n")) != NULL) {

    } else if ((ret = strstr (data, "CAPA\r\n")) != NULL) {

    // Login command
    } else if ((ret = strstr (data, "USER ")) != NULL) {

    } else if ((ret = strstr (data, "PASS ")) != NULL) {

    // ???
    } else if ((ret = strstr (data, "SASL\r\n")) != NULL) {

    } else if ((ret = strstr (data, "SASL\r\n")) != NULL) {

    } else if ((ret = strstr (data, "???")) != NULL) {

    }
}

int main (int argc, char *argv[]) {

    parser (argv[1], strlen (argv[1]));
}
