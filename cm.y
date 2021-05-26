%{
#define YYPARSER

#include "global.h"
#include "utils.h"
#include "scan.h"
#include "parse.h"

#define YYSTYPE TreeNode *

static TreeNode *savedTree;
static int yylex(void);
int yyerror(char *);

%}

%token ENDFILE ERROR
%token INT VOID FLOAT
%left ID NUM FLOAT_NUM
%left '('
%nonassoc LT LE GT GE EQ NEQ
%token IF WHILE RET
%nonassoc LOWER_ELSE
%nonassoc ELSE

%% 

program:
    declaration_list
    {
        savedTree = $1;
        // printMsg("porgram");
    }
    ;

declaration_list : 
    declaration_list declaration
    {
        $$ = addSibling($1, $2);
        // printMsg("declaration list 1");
    }
    | declaration
    {   
        $$ = $1;
        // printMsg("declaration list 2");
    }
    ;

declaration:
    var_declaration
    { 
        $$ = $1;
        // printMsg("declaration 1");
    }
    | fun_declaration
    { 
        $$ = $1; 
        // printMsg("declaration 2");
    }
    ;

var_declaration:
    type_specifier _id ';'
    { 
        $$ = $1;
        $$->child[0] = $2;
        // printMsg("var_declaration 1");
        // addChild($$, $2);
    }
    | type_specifier _id vector_dimension ';'
    { 
        $$ = $1;
        $2->is_vector = 1;
        $$->child[0] = $2;
        $2->child[1] = $3;
        // printMsg("var_declaration 2");
        // addChild($$, $2);
        // addChild($2, $4);
    }
    | type_specifier _id '=' _num ';'
    { 
        $$ = $1;
        $$->child[0] = $2;
        $$->child[1] = $4;
        // printMsg("var_declaration 3");
    }
    | type_specifier _id '=' simple_expression ';'
    { 
        $$ = $1;
        $$->child[0] = $2;
        $$->child[1] = $4;
        // printMsg("var_declaration 4");
    }
    ;
vector_dimension:
    '[' _num ']' vector_dimension
    {
        $$ = $2;
        $$->child[0] = $4;
        // printMsg("vector_dimension 1");
    }
    | %empty
    {
        $$ = NULL;
        // printMsg("vector_dimension 2");
    }

type_specifier:
    INT
    { 
        $$ = newExpNode(TypeK);
        $$->type = Integer;
        $$->attr.name = copyString(tokenString);
        // printMsg("type_specifier 1");
    }
    | VOID
    { 
        $$ = newExpNode(TypeK);
        $$->type = Void;
        $$->attr.name = copyString(tokenString);
        // printMsg("type_specifier 2");
    }
    | FLOAT
    {
        $$ = newExpNode(TypeK);
        $$->type = Float;
        $$->attr.name = copyString(tokenString);
    }
    ;

fun_declaration:
    type_specifier _id '(' params ')'
    { 
        // printMsg("fun_declaration 1");
        $$ = newStmtNode(FuncK);
        $$->attr.name = $2->attr.name;
        // addChild($$, $4);
        $$->child[0] = $4;
    }
    | type_specifier _id '(' params ')' compound_stmt
    { 
        // printMsg("fun_declaration 2");
        $$ = newStmtNode(FuncK);
        $$->attr.name = $2->attr.name;
        // addChild($$, $4);
        // addSibling($4, $6);
        $$->child[0] = $4;
        $$->child[1] = $6;
        if (!strcmp($1->attr.name, "int"))
            $$->type = Integer;
        else
            $$->type = Void;
    }
    ;

params:
    param_list
    { 
        // printMsg("params 1");
        $$ = newStmtNode(ParamsK);
        // $$->firstchild = $1;
        // addChild($$, $1);
        $$->child[0] = $1;
    }
    | VOID
    { 
        $$ = NULL; 
        printMsg("params 2");
    }
    | %empty
    { $$ = NULL; }
    ;

param_list:
    param_list ',' param
    { 
        // printMsg("param_list 1");
        $$ = addSibling($1, $3);
    }
    | param
    { 
        $$ = $1; 
        printMsg("param_list 2");
    }
    ;

param:
    type_specifier _id
    { 
      $$ = $1;
    // printMsg("param 1");
    //   addChild($$, $2);
      $$->child[0] = $2;
      $2->is_vector = 0;
    }
    |  type_specifier _id '[' ']'
    { 
        printMsg("param 2");
        $$ = $1;
        // addChild($$, $2);
        $$->child[0] = $2;
        $2->is_vector = 1;
    }
    ;

compound_stmt:
    '{' local_declarations statement_list '}'
    { 
        $$ = addSibling($2, $3);
        // printMsg("compound_stmt");
    }
    ;

local_declarations:
    local_declarations var_declaration 
    { 
        // printMsg("local_declarations 1");
        $$ = addSibling($1, $2);   
    }
    | %empty
    { 
        $$ = NULL; 
        // printMsg("local_declarations 2");
    }
    ;

statement_list: 
    statement_list statement
    { 
        // printMsg("statement_list 1");
        $$ = addSibling($1, $2);
    }
    | %empty 
    {
        $$ = NULL; 
        // printMsg("statement_list 2");
    }
    ;

statement:
    expression_stmt
    { 
        $$ = $1; 
        // printMsg("statement 1");
    }
    | compound_stmt
    { 
        $$ = $1;
        // printMsg("statement 2");
    }
    | selection_stmt
    { 
        $$ = $1;
        // printMsg("statement 3");
    }
    | iteration_stmt
    { 
        $$ = $1;
        // printMsg("statement 4");
    }
    | return_stmt
    { 
        $$ = $1;
        // printMsg("statement 5");
    }
    ;

expression_stmt:
    expression ';'
    { 
        $$ = $1;
        // printMsg("expression_stmt 1");
    }
    | ';'
    { 
        $$ = NULL;
        // printMsg("expression_stmt 2");
    }
    ;

selection_stmt:
    IF '(' expression ')' statement %prec LOWER_ELSE
    { 
        // printMsg("selection_stmt 1");
        $$ = newStmtNode(IfK);
        // addChild($$, $3);
        // addSibling($3, $5);
         $$->child[0] = $3;
         $$->child[1] = $5;
    }
    | IF '(' expression  ')' statement ELSE statement
    { 
        // printMsg("selection_stmt 2");
        $$ = newStmtNode(IfK);
        $$->child[0] = $3;
        $$->child[1] = $5;
        $$->child[2] = $7;
        // addChild($$, $3);
        // addSibling($3, $5);
        // addSibling($5, $7);
    }
    ;

iteration_stmt:
    WHILE '(' expression ')' statement
    { 
        // printMsg("iteration_stmt 1");
        $$ = newStmtNode(WhileK);
        // addChild($$, $3);
        // addSibling($3, $5);
        $$->child[0] = $3;
        $$->child[1] = $5;
    }
    ;

return_stmt:
    RET ';'
    { 
        // printMsg("return_stmt 1");
        $$ = newStmtNode(ReturnK); 
    }
    | RET expression    
    { 
        // printMsg("return_stmt 2");
        $$ = newStmtNode(ReturnK);
        // addChild($$, $2);
        $$->child[0] = $2;
    }
    ;

expression:
    var '=' simple_expression 
    {
        // printMsg("expression 1");
        $$ = newStmtNode(AssignK);
        // addChild($$, $1);
        // addSibling($1, $3);
        $$->child[0] = $1;
        $$->child[1] = $3;
    }
    | simple_expression
    { 
        $$ = $1;
        // printMsg("expression 2");
    }
    ;

var:
    _id %prec ID 
    { 
        // printMsg("var 1");
        $$ = $1;
        $1->is_vector = 0;
    }
    /* | _id '[' expression ']'
    {
        printMsg("var 2");
        $$ = newExpNode(VectorK);
        $$->attr.name = $1->attr.name;
        $$->is_vector = 1;
        // addChild($$, $3);
        $$->child[0] = $3;
    } */
    | _id '[' _num ',' _num ']' 
    {
        // printMsg("var 2");
        $$ = newExpNode(VectorK);
        $$->attr.name = $1->attr.name;
        $$->is_vector = 1;
        // addChild($$, $3);
        $$->child[0] = $3;
        $$->child[0] = $5;
    }
    | _id vector_dimension
    {
        // printMsg("var 3");
        $$ = newExpNode(VectorK);
        $$->attr.name = $1->attr.name;
        $$->is_vector = 1;
        // addChild($$, $3);
        $$->child[0] = $2;
    }
    ;

simple_expression:
    additive_expression relop additive_expression
    { 
        // printMsg("simple_expression 1");
        $$ = newExpNode(OpK);
        $$->attr.op = $2->attr.op;
        // addChild($$, $1);
        // addSibling($1, $3);
        $$->child[0] = $1;
        $$->child[1] = $3;
    }
    | additive_expression
    { 
        $$ = $1;
        // printMsg("simple_expression 2");
    }
    | ERROR additive_expression
    {
        $$ = $2;
        // printMsg("simple_expression 3");
    }
    ;

relop:
    LE 
    { $$ = newExpNode(OpK); $$->attr.op = LE;}
    | LT 
    { $$ = newExpNode(OpK); $$->attr.op = LT; }
    | GT 
    { $$ = newExpNode(OpK); $$->attr.op = GT; }
    | GE 
    { $$ = newExpNode(OpK); $$->attr.op = GE; }
    | EQ
    { $$ = newExpNode(OpK); $$->attr.op = EQ;} 
    | NEQ
    { $$ = newExpNode(OpK); $$->attr.op = NEQ; }
    ;

additive_expression:
    additive_expression addop term
    { 
        // printMsg("additive_expression 1");
        $$ = newExpNode(OpK);
        $$->attr.op = $2->attr.op;
        // $$ = $2;
        // addChild($$, $1);
        // addSibling($1, $3);
        $$->child[0] = $1;
        $$->child[1] = $3;
    }
    | term
    { 
        $$ = $1; 
        // printMsg("addictive_expression 2");
    }
    ;

addop:
    '+' 
    { 
        $$ = newExpNode(OpK); 
        $$->attr.op = '+';
        // printMsg("addop 1");
    }
    | '-'
    { 
        $$ = newExpNode(OpK); 
        $$->attr.op = '-'; 
        // printMsg("addop 2");
    }
    ;

term:
    term mulop factor
    {
        // printMsg("term 1");
        $$ = newExpNode(OpK);
        //   $$ = $2;
        //   addChild($$, $1);
        //   addSibling($1, $3);
        $$->child[0] = $1;
        $$->child[1] = $3;
        $$->attr.op = $2->attr.op;
    }
    | factor
    { 
        // printMsg("term 2");
        $$ = $1; 
    }
    ;

mulop:
    '*'
    { 
        $$ = newExpNode(OpK); 
        $$->attr.op = '*';
        // printMsg("mulop 1");
    } 
    | '/'
    { 
        $$ = newExpNode(OpK); 
        $$->attr.op = '/';
        // printMsg("mulop 2"); 
    }
    ;

factor:
    '(' expression ')'
    { 
        // printMsg("factor 1");
        $$ = $2; 
    }
    | var
    { 
        $$ = $1;
        // printMsg("factor 2"); 
    }
    | call
    { 
        $$ = $1;
        // printMsg("factor 3");
    }
    | _num
    { 
        $$ = $1;
        // printMsg("factor 4");
    }
    | _float_num
    {
        $$ = $1;
        // printMsg("factor 5");
    }
    ;

call:
    _id '(' args ')' 
    { 
        // printMsg("call 1");
        $$ = newStmtNode(CallK);
        $$->attr.name = $1->attr.name;
        // addChild($$, $3);
        $$->child[0] = $3;
    }
   ;

args:
    arg_list
    { 
        // printMsg("args 1");
        $$ = $1;
    }
    | %empty
    { 
        $$ = NULL;
        // printMsg("args 2");
    }
    ;

arg_list:
    arg_list ',' expression
    { 
        // printMsg("arg_list 1");
        $$ = addSibling($1, $3); 
    }
    | expression
    { 
        // printMsg("arg_list 2");
        $$ = $1; 
    }
    ;
_float_num:
    FLOAT_NUM
    {
        // printMsg("float_num 1");
        $$ = newExpNode(ConstK);
        $$->attr.float_val = atof(copyString(tokenString));
    }
_id:
    ID
    { 
        // printMsg("_id 1");
        $$ = newExpNode(IdK); 
        $$->attr.name = copyString(tokenString);
    }
    ;

_num:
    NUM
    { 
        // printMsg("_num 1");
        $$ = newExpNode(ConstK);
        $$->attr.val = atoi(copyString(tokenString));
    }
    ;

%%

int yyerror(char *s)
{
    fprintf(listing, "Syntax error at line %d: %s\n", lineno, s);
    fprintf(listing, "Current token: ");
    printToken(yychar, tokenString);
    Error = TRUE;
    return 0;
}

static int yylex(void)
{
    return getToken();
}

TreeNode * parse(void)
{
    yyparse();
    return savedTree;
}
