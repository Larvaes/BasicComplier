%option noyywrap

D			[0-9]
L			[a-zA-Z_]
H			[a-fA-F0-9]
E			[Ee][+-]?{D}+
FS			(f|F|l|L)
IS			(u|U|l|L)*

%{
#include <stdio.h>
#include <string.h>
#include "calc.tab.h"
int getRegID(char*);
%}

%%
[ \t]         ;

{D}+            { yylval = atoi(yytext); return NUM; }
{H}+h            { yylval = strtol(yytext, NULL, 16); return NUM; }
[+]             { return PLUS; }
[-]             { return MINUS; }
[*]             { return MUL; }
[/]             { return DIV; }
[\\]            { return MOD; }
\n              { return LINE; }
[(]             { return PARl; }
[)]             { return PARr; }
[aA][nN][dD]           { return AND; }
[oO][rR]            { return OR; }
[nN][oO][tT]           { return NOT; }
[pP][uU][sS][hH]    { return PUSH; }
[pP][oO][pP]        { return POP; }
[sS][hH][oO][wW]    { return SHOW; }
[lL][oO][aA][dD]    { return LOAD; }
$size               { return SIZE; }
$acc                { return ACC; }
$top                { return TOP; }
$r[a-zA-Z]          { yylval = (int)getRegID(yytext);return REG;printf("%d",yylval); }
.                { return yytext[0]; }
%%

int getRegID(char *input){
    int result = 0;
    if(input[strlen(input)-1] >= 'A' && input[strlen(input)-1] <= 'Z')
        result = input[strlen(input)-1] - 'A';
    else if(input[strlen(input)-1] >= 'a' && input[strlen(input)-1] <= 'z')
        result = input[strlen(input)-1] - 'a';
    return result;
}
