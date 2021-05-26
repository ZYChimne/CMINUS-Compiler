#ifndef _SCAN_H_
#define _SCAN_H_
#define MAXTOKENLEN 50
extern char tokenString[MAXTOKENLEN + 1];
void printToken(TokenType t, const char *tokenString);
TokenType getToken(void);
#endif
