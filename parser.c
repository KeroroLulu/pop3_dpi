#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>

#define FROM_SERVER 0
#define FROM_CLIENT 1

#define VERDICT_OK 0
#define VERDICT_PARAM_1 1
#define VERDICT_PARAM_2 2
#define VERDICT_TOO_FEW 3
#define VERDICT_TOO_MANY 4

#define PARAM_INT 0
#define PARAM_STRING 1

#define NO_TYPE 0
#define NUMBER 1

void printAndCheckPOP3 (int from, char *cmd, char *params, int param, ...) {

    int paramCounter = 0;
    va_list ap;
    va_start (ap, param);
    int verdict = 0;

    // Display commands
    fprintf (stdout, "+ -------------------------------- +\n");
    if (from == FROM_SERVER)
        fprintf (stdout, "+ SERVER : [%s]", cmd);

    else if (from == FROM_CLIENT)
        fprintf (stdout, "+ CLIENT : [%s]", cmd);
    
    for (int i = 0 ; i < 22 - strlen (cmd) ; i++)
        fprintf (stdout, " ");

    fprintf (stdout, "+\n");
    fprintf (stdout, "+ -------------------------------- +\n");

    // Display Param
    if (param > 0 && params == NULL)
            verdict = VERDICT_TOO_FEW;
    else if (param > 0) {

        for (char *p = strtok (strdup (params)," ") ; p != NULL ; p = strtok (NULL, " ")) {

            if (paramCounter < param) {
                
                switch (va_arg (ap, int)) {

                    case PARAM_INT :
                        fprintf (stdout, "+ [INT]    :");
                        for (int k = 0 ; k < strlen (p) ; k++) {

                            if (p[k] < '0' || p[k] > '9') {

                                if (paramCounter == 0)
                                    verdict = VERDICT_PARAM_1;
                                else if (paramCounter == 1)
                                    verdict = VERDICT_PARAM_2;
                                break;
                            }
                        }

                        break;

                    case PARAM_STRING :
                        fprintf (stdout, "+ [STRING] :");
                        break;
                }

            } else
                fprintf (stdout, "+ [??????] :");

            fprintf (stdout, "%s", p);
            for (int i = 0 ; i < 23 - strlen (p) ; i++)
                    fprintf (stdout, " ");
                fprintf (stdout, "+\n");

            paramCounter++;
        }

        if (paramCounter < param)
            verdict = VERDICT_TOO_FEW;
        else if (paramCounter > param)
            verdict = VERDICT_TOO_MANY;

        fprintf (stdout, "+ -------------------------------- +\n");
    }

    // Verdict
    if (verdict == VERDICT_OK)
        fprintf (stdout, "+ Verdict : OK                     +\n");
    else if (verdict == VERDICT_PARAM_1)
        fprintf (stdout, "+ Verdict : FAIL with param 1      +\n");
    else if (verdict == VERDICT_PARAM_2)
        fprintf (stdout, "+ Verdict : FAIL with param 2      +\n");
    else if (verdict == VERDICT_TOO_MANY)
        fprintf (stdout, "+ Verdict : FAIL too many param    +\n");
    else if (verdict == VERDICT_TOO_FEW)
        fprintf (stdout, "+ Verdict : FAIL too few param     +\n");

    fprintf (stdout, "+ -------------------------------- +\n\n");
}

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

        printAndCheckPOP3 (FROM_CLIENT, "QUIT", NULL, 0);

    } else if ((ret = strstr (data, "RSET\r\n")) != NULL) {

    } else if ((ret = strstr (data, "UIDL\r\n")) != NULL) {

    } else if ((ret = strstr (data, "CAPA\r\n")) != NULL) {

        printAndCheckPOP3 (FROM_CLIENT, "CAPA", NULL, 0);

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

    /*
    printAndCheckPOP3 (FROM_CLIENT, "LIST", NULL, 0);
    printAndCheckPOP3 (FROM_CLIENT, "QUIT", NULL, 2, PARAM_INT, PARAM_INT);
    printAndCheckPOP3 (FROM_CLIENT, "QUIT", "ababab", 2, PARAM_STRING, PARAM_INT);
    printAndCheckPOP3 (FROM_CLIENT, "QUIT", "ababab sdlkfj", 2, PARAM_STRING, PARAM_INT);
    printAndCheckPOP3 (FROM_CLIENT, "QUIT", "lskmdfj 122", 2, PARAM_STRING, PARAM_INT);
    printAndCheckPOP3 (FROM_CLIENT, "QUIT", "ababab sdlkfj lsdkf", 2, PARAM_STRING, PARAM_INT);
    printAndCheckPOP3 (FROM_SERVER, "+OK", NULL, 1, 100);
    printAndCheckPOP3 (FROM_CLIENT, "QUIT", NULL, 3, PARAM_INT, PARAM_INT, PARAM_STRING);
    */
}
