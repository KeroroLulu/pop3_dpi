#pragma once

typedef enum {
    Ok,
    Err,
    None
} Status;

typedef enum {
    Resp,
    Quit
} Type;

typedef char* ccstr;

struct sArg_list {
    ccstr arg;
    struct sArg_list* next;
};
typedef struct sArg_list Arg_list;

typedef struct {
    Status status;
    Type type;
    Arg_list* args;
} Command;

struct sCommand_list {
    Command cmd;
    struct sCommand_list* next;
};
typedef struct sCommand_list Command_list;

