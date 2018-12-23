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
\+OK { return OK; }
\-ERR { return ERR; }
"." { return TERMINATOR; }
[0-9]+ { return NUMBER; }
(?i:QUIT) { return QUIT; }
[a-zA-Z0-9]+ { return ANY; }
%%
