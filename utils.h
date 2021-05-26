#ifndef _UTILS_H_
#define _UTILS_H_

#include "global.h"

typedef enum
{
    Empty,
    IntConst,
    String,
    Temp,
    Label
} OperandKind;

typedef struct
{
    OperandKind kind;
    union
    {
        int val;
        struct
        {
            const char *name;
        } variable;
    } contents;
} Operand;

typedef enum
{
    StmtK,
    ExpK
} NodeKind;
typedef enum
{
    IfK,
    WhileK,
    AssignK,
    ReturnK,
    FuncK,
    CallK,
    ParamsK
} StmtKind;

typedef enum
{
    OpK,
    ConstK,
    IdK,
    TypeK,
    VectorK
} ExpKind;

typedef enum
{
    Void,
    Integer,
    Boolean,
    Float
} ExpType;

#define MAXCHILDREN 6

typedef struct treeNode
{
    struct treeNode *child[MAXCHILDREN];
    struct treeNode *sibling;
    int lineno;
    int already_seem;
    NodeKind nodekind;
    union
    {
        StmtKind stmt;
        ExpKind exp;
    } kind;
    union
    {
        TokenType op;
        int val;
        float float_val;
        char *name;
    } attr;
    char *scope;
    Operand *oper;
    int is_vector;
    ExpType type; /* for type checking of exps */
} TreeNode;

/* Procedure printToken prints a token 
 * and its lexeme to the listing file
 */
void printToken(TokenType, const char *);

/* Function newStmtNode creates a new statement
 * node for syntax tree construction
 */
TreeNode *newStmtNode(StmtKind);

/* Function newExpNode creates a new expression 
 * node for syntax tree construction
 */
TreeNode *newExpNode(ExpKind);

/* Function copyString allocates and makes a new
 * copy of an existing string
 */
char *copyString(char *);

/* procedure printTree prints a syntax tree to the 
 * listing file using indentation to indicate subtrees
 */
void printTree(TreeNode *);

TreeNode *addSibling(TreeNode *, TreeNode *);
TreeNode *addChild(TreeNode *, TreeNode *);
void printMsg(char *msg);

#endif
