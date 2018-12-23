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
[0-9]+ { return NUMBER; }
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
[a-zA-Z0-9]+ { return ANY; }
%%
