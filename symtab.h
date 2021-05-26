#ifndef _SYMTAB_H_
#define _SYMTAB_H_

typedef struct LineListRec
{
  int lineno;
  struct LineListRec *next;
} * LineList;

typedef struct BucketListRec
{
  char *name;
  LineList lines;
  int memloc; /* memory location for variable */
  int is_vector;
  struct BucketListRec *next;
  char *scope;
  char *typeID;
  char *typedata;
} * BucketList;

void st_insert(char *name, int lineno, int loc, int is_vector, char *scope, char *typeID, char *typedata);

BucketList st_lookup(char *name, char *scope);

int checkFunctionType(char *name);

void printSymTab(FILE *listing);

#endif
