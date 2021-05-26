#include "global.h"

#define NO_PARSE FALSE
#define ANALYZE TRUE
#define NO_CODE TRUE

#include "utils.h"

#if NO_PARSE
#include "scan.h"
#else
#include "parse.h"
#if !ANALYZE
#include "analyze.h"
#if !NO_CODE
#include "cgen.h"
#endif
#endif
#endif

int lineno = 0;
FILE* source;
FILE* listing;
FILE* code;

int EchoSource = FALSE;
int TraceScan = TRUE;
int TraceParse = TRUE;
int TraceAnalyze = FALSE;
int TraceCode = FALSE;

int Error = FALSE;

int main(int argc, char* argv[])
{
    TreeNode* syntaxTree;
    char pgm[120];
    if (argc != 2)
    {
        fprintf(stderr, "usage: %s <filename>\n", argv[0]);
        exit(1);
    }
    strcpy(pgm, argv[1]);

    source = fopen(pgm, "r");
    if (source == NULL)
    {
        fprintf(stderr, "File %s not found\n", pgm);
        exit(1);
    }
    listing = stdout;
    fprintf(listing, "\nC- COMPILATION: %s\n", pgm);

#if NO_PARSE
    while (getToken() != ENDFILE)
        ;
#else
    syntaxTree = parse();
    if (TraceParse)
    {
        fprintf(listing, "\nSyntax tree:\n");
        printTree(syntaxTree);
    }
#if ANALYZE
    // 分析表
    if (!Error)
    {
        fprintf(listing, "\nBuilding Symbol Table...\n");
        buildSymtab(syntaxTree, 0);
        fprintf(listing, "\nChecking Types...\n");
        typeCheck(syntaxTree);
        fprintf(listing, "\nType Checking Finished\n");
    }
    else
    {
        fprintf(listing, "\nBuilding Symbol Table...\n");
        buildSymtab(syntaxTree, 0);
        fprintf(listing, "\nChecking Types...\n");
        typeCheck(syntaxTree);
        fprintf(listing, "\nType Checking Finished\n");
    }

    // 生成中间代码
    /*
    if(!Error)
    {
        char *codefile;
        int fnlen = strcspn(pgm, ".");
        codefile = (char *)calloc(fnlen+4, sizeof(char));
        strncpy(codefile, pgm, fnlen);
        strcat(codefile, ".tm");
        code = fopen(codefile, "w");
        if(code == NULL)
        {
            printf("Unable to open %s\n", codefile);
            fclose(code);
        }
    }
    */
#endif
#endif
    fclose(source);
    return 0;
}
