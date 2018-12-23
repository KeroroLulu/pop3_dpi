%{
#include <stdio.h>
#include <stdlib.h>
#include "types.h"
extern int yylex();
extern int yyparse();
extern FILE* yyin;
void yyerror(const char* s);

Arg_list* make_arg(ccstr str, Arg_list* next) {
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

%type<arg_list> args
%type<command> resp
%type<command> req
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
       ;

req: QUIT CRLF { Command tmp = { .status = None, .type = Quit, .args = NULL }; $$ = tmp; }

resp: OK SPACE args { Command tmp = { .status = Ok, .type = Resp, .args = $3 }; $$ = tmp; }
    | ERR SPACE args { Command tmp = { .status = Err, .type = Resp, .args = $3 }; $$ = tmp; }
    ;

args: ANY SPACE args { $$ = make_arg($1, $3); }
    | ANY CRLF { $$ = make_arg($1, NULL); }
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
