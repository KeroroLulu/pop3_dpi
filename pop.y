%{
#include <stdio.h>
#include <stdlib.h>
#include "types.h"
extern int yylex();
extern int yyparse();
extern FILE* yyin;
void yyerror(const char* s);

Arg_list* make_arg(Value str, Arg_list* next) {
    Arg_list* ret = malloc(sizeof(Arg_list));
    ret->arg = str;
    ret->next = next;
    return ret;
}

Command_list* make_cmdlist_elt(Command str, Command_list* next) {
    Command_list* ret = malloc(sizeof(Command_list));
    ret->cmd = str;
    ret->next = next;
    return ret;
}

Value make_int(int val) {
    Value ret = { .tag = EInt, .val.UInt = val };
    return ret;
}
Value make_string(char* val) {
    Value ret = { .tag = EString, .val.UString = val };
    return ret;
}

%}

%union Parser {
    Status t_status;
    char* sval;
    Command command;
    Command_list* cmdlist;
    Arg_list* arg_list;
    int ival;
}

%define parse.error verbose

%token SPACE
%token TERMINATOR
%token CRLF
%token<t_status> OK
%token<t_status> ERR
%token<sval> ANY
%token<ival> NUMBER
%token QUIT
%token STAT
%token LIST
%token RETR
%token NOOP
%token DELE
%token RSET
%token TOP
%token UIDL
%token USER
%token PASS
%token APOP

%type<arg_list> args
%type<command> resp
%type<command> req
%type<command> line
%type<cmdlist> command
%type<cmdlist> pop3

%start pop3

%%
pop3: { $$ = NULL; }
    | command { $$ = $1; }
    ;

command: { $$ = NULL; }
       | resp command { $$ = make_cmdlist_elt($1, $2); }
       | req command { $$ = make_cmdlist_elt($1, $2); }
       | line command { $$ = make_cmdlist_elt($1, $2); }
       ;

line: args CRLF { Command tmp = { .status = None, .type = Line, .args = $1 }; $$ = tmp; }
    | TERMINATOR CRLF CRLF { Command tmp = { .status = None, .type = EOML, .args = NULL }; $$ = tmp; }
    ;

req: QUIT CRLF { Command tmp = { .status = None, .type = Quit, .args = NULL }; $$ = tmp; }
   | STAT CRLF { Command tmp = { .status = None, .type = Stat, .args = NULL }; $$ = tmp; }
   | NOOP CRLF { Command tmp = { .status = None, .type = Noop, .args = NULL }; $$ = tmp; }
   | RSET CRLF { Command tmp = { .status = None, .type = Noop, .args = NULL }; $$ = tmp; }
   | LIST CRLF { Command tmp = { .status = None, .type = List, .args = NULL }; $$ = tmp; }
   | LIST SPACE args { Command tmp = { .status = None, .type = List, .args = $3 }; $$ = tmp; }
   | UIDL CRLF { Command tmp = { .status = None, .type = UIDL, .args = NULL }; $$ = tmp; }
   | UIDL SPACE args { Command tmp = { .status = None, .type = Uidl, .args = $3 }; $$ = tmp; }
   | USER SPACE args { Command tmp = { .status = None, .type = User, .args = $3 }; $$ = tmp; }
   | PASS SPACE args { Command tmp = { .status = None, .type = Pass, .args = $3 }; $$ = tmp; }
   | APOP SPACE args { Command tmp = { .status = None, .type = Apop, .args = $3 }; $$ = tmp; }
   | TOP SPACE args { Command tmp = { .status = None, .type = Top, .args = NULL }; $$ = tmp; }
   | RETR SPACE args { Command tmp = { .status = None, .type = Retr, .args = $3 }; $$ = tmp; }
   | DELE SPACE args { Command tmp = { .status = None, .type = Dele, .args = $3 }; $$ = tmp; }
   ;

resp: OK SPACE args { Command tmp = { .status = Ok, .type = Resp, .args = $3 }; $$ = tmp; }
    | ERR SPACE args { Command tmp = { .status = Err, .type = Resp, .args = $3 }; $$ = tmp; }
    ;

args: NUMBER SPACE args { $$ = make_arg(make_int($1), $3); }
    | NUMBER CRLF { $$ = make_arg(make_int($1), NULL); }
    | ANY SPACE args { $$ = make_arg(make_string($1), $3); }
    | ANY CRLF { $$ = make_arg(make_string($1), NULL); }
    | CRLF { $$ = NULL; }
    ;

%%

int main() {
    yyin = stdin;
    do {
        yyparse();
    } while(!feof(yyin));
    return 0;
}
void yyerror(const char* s) {
    fprintf(stderr, "Parse error: %s\n", s);
    exit(1);
}
