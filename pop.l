%option noyywrap

%{
#include <stdio.h>

#define YY_DECL int yylex()

#include "types.h"
#include "pop.tab.h"

%}

%%

[  ] { return SPACE; }
\r\n { return CRLF; }
\n\r { return CRLF; }
\+OK { return OK; }
\-ERR { return ERR; }
"." { return TERMINATOR; }
[0-9]{1,40} { return NUMBER; }
(?i:QUIT) { return QUIT; }
(?i:LIST) { return LIST; }
(?i:STAT) { return STAT; }
(?i:RETR) { return RETR; }
(?i:NOOP) { return NOOP; }
(?i:DELE) { return DELE; }
(?i:RSET) { return RSET; }
(?i:TOP) { return TOP; }
(?i:UIDL) { return UIDL; }
(?i:USER) { return USER; }
(?i:PASS) { return PASS; }
(?i:APOP) { return APOP; }
(?i:CAPA) { return CAPA; }
(?i:SASL) { return SASL; }
(?i:RESP\-CODES) { return RESPCODES; }
(?i:LOGIN\-DELAY) { return LOGINDELAY; }
(?i:PIPELINING) { return PIPELINING; }
(?i:EXPIRE) { return EXPIRE; }
(?i:NEVER) { return NEVER; }
(?i:IMPLEMENTATION) { return IMPLEMENTATION; }
[a-zA-Z0-9]{1,40} { return ANY; }
[a-zA-Z0-9 \t\.\-_] { return LINE; }
%%

void scan_string(const char* str)
{
    yy_switch_to_buffer(yy_scan_string(str));
}
