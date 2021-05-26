%option noyywrap
%{
#include "global.h"
#include "scan.h"
#include "utils.h"

char tokenString[MAXTOKENLEN+1];
static int yylex(void);
%}

digit   [0-9]
number  {digit}+
letter  [a-zA-Z]
id      {letter}+
newline \r\n
whitespace  [ \t]+
float_num {number}\.{number}

%%

"//".*          { /* DO NOTHING */ }
"#".*           { /*SKIP PREPROCESSING*/ }  
"if"            {return IF;}
"else"          {return ELSE;}
"int"           {return INT;}
"void"          {return VOID;}
"float"         {return FLOAT;}
"return"        {return RET;}
"!="            {return NEQ;}
"=="            {return EQ;}
"+"|"-"|"*"|"/"|"("|")"|"["|"]"|"{"|"}"|","|";"|"=" {return *yytext;}
"<="            {return LE;}
">="            {return GE;}
"<"             {return LT;}
">"             {return GE;}
{number}        {return NUM;}
{float_num}     {return FLOAT_NUM;}
{id}            {return ID;}    
{newline}       {lineno++;}
{whitespace}    {/*skip whitespace*/}
"/*"           {
                    char c,ant;
                    c = input();
                    do{
                        ant = c;
                        c = input();
                        if (c == EOF) break;
                        if (c == '\n') lineno++;
                    } while (ant != '*' || c!='/');
                }
.               {return ERROR;}

%%

TokenType getToken()
{   
    static int firstTime=TRUE;
    TokenType currentToken;
    if(firstTime){
        firstTime=FALSE;
        lineno++;
        yyin = source;
        yyout = listing;
    }
    currentToken = yylex();
    strncpy(tokenString, yytext, MAXTOKENLEN);
    if(TraceScan) {
        fprintf(listing, "\t%d: ", lineno);
        printToken(currentToken, tokenString);
    }
    return currentToken;
}
