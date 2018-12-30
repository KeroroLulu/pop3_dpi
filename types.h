#pragma once

typedef enum {
    Ok,
    Err,
    None
} Status;

typedef enum {
    Resp,
    Stat,
    List,
    Line,
    EOML, // End Of MultiLine
    Retr,
    Dele,
    Noop,
    Rset,
    Top,
    Uidl,
    User,
    Pass,
    Apop,
    Capa,
    CapaTop,
    CapaUser,
    CapaSasl,
    CapaRespCodes,
    CapaLoginDelay,
    CapaPipe,
    CapaExpire,
    CapaImpl,
    Quit
} Type;

enum EValue {
    EInt,
    EString
};
union UValue {
    int UInt;
    char* UString;
};

typedef struct {
    union UValue val;
    enum EValue tag;
} Value;

typedef char* ccstr;

struct sArg_list {
    Value arg;
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
