#include "global.h"
#include "symtab.h"

#define SIZE 211
#define SHIFT 4

static int hash(char *key)
{
  int temp = 0;
  int i = 0;
  while (key[i] != '\0')
  {
    temp = ((temp << SHIFT) + key[i]) % SIZE;
    ++i;
  }
  return temp;
}

static BucketList hashTable[SIZE];

int checkFunctionType(char *name)
{
  int h = hash(name);
  int kasa;
  BucketList l = hashTable[h];
  while ((l != NULL) && !((strcmp(name, l->name) == 0)))
    l = l->next;
  if (l == NULL)
    return 2;
  else if (strcmp(l->typedata, "int") == 0)
    return 1;
  else
    return 0;
}

void st_insert(char *name, int lineno, int loc, int is_vector, char *scope, char *typeID, char *typedata)
{
  int h = hash(name);
  BucketList l = hashTable[h];
  while ((l != NULL) && !((strcmp(name, l->name) == 0) && ((strcmp(scope, l->scope) == 0) || (strcmp(l->scope, " ") == 0))))
    l = l->next;
  if (l == NULL) /* variable not yet in table */
  {
    l = (BucketList)malloc(sizeof(struct BucketListRec));
    l->name = name;
    l->scope = scope;
    l->typeID = typeID;
    l->typedata = typedata;
    l->lines = (LineList)malloc(sizeof(struct LineListRec));
    l->lines->lineno = lineno;
    l->memloc = loc;
    l->is_vector = is_vector;
    l->lines->next = NULL;
    l->next = hashTable[h];
    hashTable[h] = l;
  }
  else /* found in table, so just add line number */
  {
    LineList t = l->lines;
    while (t->next != NULL)
      t = t->next;
    t->next = (LineList)malloc(sizeof(struct LineListRec));
    t->next->lineno = lineno;
    t->next->next = NULL;
  }
} /* st_insert */

BucketList st_lookup(char *name, char *scope)
{
  int h = hash(name);
  BucketList l = hashTable[h];
  while ((l != NULL) && !((strcmp(name, l->name) == 0) && ((strcmp(scope, l->scope) == 0) || (strcmp(l->scope, " ") == 0))))
    l = l->next;
  if (l == NULL)
    return NULL;
  else
    return l;
}

void printSymTab(FILE *listing)
{
  int i;
  fprintf(listing, "Variable Name  Location   Scope   TypeID   Type Data   Line Numbers\n");
  fprintf(listing, "-------------  --------   -----   ------   ---------   ------------\n");
  for (i = 0; i < SIZE; ++i)
  {
    if (hashTable[i] != NULL)
    {
      BucketList l = hashTable[i];
      while (l != NULL)
      {
        LineList t = l->lines;
        fprintf(listing, "%-14s ", l->name);
        fprintf(listing, "%-9d  ", l->memloc);
        fprintf(listing, "%-7s ", l->scope);
        fprintf(listing, "%-8s ", l->typeID);
        fprintf(listing, "%-10s ", l->typedata);
        while (t != NULL)
        {
          fprintf(listing, "%4d ", t->lineno);
          t = t->next;
        }
        fprintf(listing, "\n");
        l = l->next;
      }
    }
  }
} /* printSymTab */