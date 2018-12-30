%{
#include <stdio.h>
#include <stdlib.h>
#include "types.h"
extern int yylex();
extern int yyparse();
extern FILE* yyin;
void yyerror(const char* s);

Command_list* list_of_commands___;

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
%token<sval> LINE
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
%token CAPA
%token SASL
%token RESPCODES
%token LOGINDELAY
%token PIPELINING
%token EXPIRE
%token NEVER
%token IMPLEMENTATION

%type<arg_list> args
%type<command> resp
%type<command> req
%type<command> line
%type<command> capa
%type<cmdlist> command
%type<cmdlist> pop3

%start main

%%
main: pop3 { list_of_commands___ = $1;}

pop3: { $$ = NULL; }
    | command { $$ = $1; }
    ;

command: { $$ = NULL; }
       | resp command { $$ = make_cmdlist_elt($1, $2); }
       | req command { $$ = make_cmdlist_elt($1, $2); }
       | line command { $$ = make_cmdlist_elt($1, $2); }
       | capa command { $$ = make_cmdlist_elt($1, $2); }
       ;

line: LINE CRLF { Command tmp = { .status = None, .type = Line, .args = make_arg(make_string($1), NULL) }; $$ = tmp; }
    | TERMINATOR CRLF CRLF { Command tmp = { .status = None, .type = EOML, .args = NULL }; $$ = tmp; }
    ;

req: QUIT CRLF { Command tmp = { .status = None, .type = Quit, .args = NULL }; $$ = tmp; }
   | STAT CRLF { Command tmp = { .status = None, .type = Stat, .args = NULL }; $$ = tmp; }
   | LIST CRLF { Command tmp = { .status = None, .type = List, .args = NULL }; $$ = tmp; }
   | LIST SPACE NUMBER CRLF { Command tmp = { .status = None, .type = List, .args = make_arg(make_int($3), NULL) }; $$ = tmp; }
   | RETR SPACE NUMBER CRLF { Command tmp = { .status = None, .type = Retr, .args = make_arg(make_int($3), NULL) }; $$ = tmp; }
   | DELE SPACE NUMBER CRLF { Command tmp = { .status = None, .type = Dele, .args = make_arg(make_int($3), NULL) }; $$ = tmp; }
   | NOOP CRLF { Command tmp = { .status = None, .type = Noop, .args = NULL }; $$ = tmp; }
   | RSET CRLF { Command tmp = { .status = None, .type = Noop, .args = NULL }; $$ = tmp; }
   | TOP SPACE NUMBER SPACE NUMBER CRLF{ Command tmp = { .status = None, .type = Top, .args = make_arg(make_int($3), make_arg(make_int($5), NULL)) }; $$ = tmp; }
   | UIDL CRLF { Command tmp = { .status = None, .type = UIDL, .args = NULL }; $$ = tmp; }
   | UIDL SPACE NUMBER CRLF { Command tmp = { .status = None, .type = Uidl, .args = make_arg(make_int($3), NULL) }; $$ = tmp; }
   | USER SPACE ANY CRLF { Command tmp = { .status = None, .type = User, .args = make_arg(make_string($3), NULL) }; $$ = tmp; }
   | PASS SPACE ANY CRLF { Command tmp = { .status = None, .type = Pass, .args = make_arg(make_string($3), NULL) }; $$ = tmp; }
   | APOP SPACE ANY SPACE ANY CRLF { Command tmp = { .status = None, .type = Apop, .args = make_arg(make_string($3), make_arg(make_string($5), NULL)) }; $$ = tmp; }
   | CAPA CRLF { Command tmp = { .status = None, .type = Capa, .args = NULL }; $$ = tmp;  }
   ;

capa: TOP CRLF { Command tmp = { .status = None, .type = CapaTop, .args = NULL }; $$ = tmp; }
    | USER CRLF { Command tmp = { .status = None, .type = CapaUser, .args = NULL }; $$ = tmp; }
    | SASL SPACE args CRLF { Command tmp = { .status = None, .type = CapaUser, .args = $3 }; $$ = tmp; }
    | RESPCODES CRLF { Command tmp = { .status = None, .type = CapaRespCodes, .args = NULL }; $$ = tmp; }
    | LOGINDELAY SPACE NUMBER CRLF { Command tmp = { .status = None, .type = CapaRespCodes, .args = NULL }; $$ = tmp; }
    | LOGINDELAY SPACE NUMBER SPACE USER CRLF { Command tmp = { .status = None, .type = CapaRespCodes, .args = make_arg(make_int($3), make_arg(make_string("user"), NULL))}; $$ = tmp; }
    | PIPELINING CRLF { Command tmp = { .status = None, .type = CapaPipe, .args = NULL }; $$ = tmp; }
    | EXPIRE SPACE NUMBER CRLF  { Command tmp = { .status = None, .type = CapaExpire, .args = make_arg(make_int($3), NULL) }; $$ = tmp; }
    | EXPIRE SPACE NUMBER SPACE USER CRLF { Command tmp = { .status = None, .type = CapaExpire, .args = make_arg(make_int($3), make_arg(make_string("user"), NULL)) }; $$ = tmp; }
    | EXPIRE SPACE NEVER CRLF { Command tmp = { .status = None, .type = CapaExpire, .args = make_arg(make_string("never"), NULL) }; $$ = tmp; }
    | EXPIRE SPACE NEVER SPACE USER CRLF { Command tmp = { .status = None, .type = CapaExpire, .args = make_arg(make_string("never"), make_arg(make_string("user"), NULL)) }; $$ = tmp; }
    /*| UIDL CRLF { Command tmp = { .status = None, .type = CapaUidl, .args = NULL }; $$ = tmp; }*/
    | IMPLEMENTATION SPACE args { Command tmp = { .status = None, .type = CapaImpl, .args = $3 }; $$ = tmp;  }
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


// Command_list* parse_messages(FILE* pkg) {
//     yyin = pkg;
//     do {
//         yyparse();
//     } while(!feof(yyin));
//     return 0;
// }

// int main() {
//     yyin = stdin;
//     do {
//         yyparse();
//     } while(!feof(yyin));
//     return 0;
// }
void yyerror(const char* s) {
    fprintf(stderr, "Parse error: %s\n", s);
    exit(1);
}
