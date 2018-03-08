%{
  #include <math.h>
  #include <stdio.h>
  #include <ctype.h>
  #include <stdlib.h>
  typedef struct node{
      int data;
      struct node *next;
  }node;
  int yylex (void);
  void yyerror (char const *);
  void errorHandle (int);
  void loadOp(int*, int);
  node* Push(node*, int);
  node* Pop(node*, int*);
  int reg[26] = {0};
  int acc = 0;
  int size = 0;
  int errors = 0;

  node *top = NULL;
%}
/* Bison declarations.  */
%token NUM LINE PUSH POP SHOW LOAD ERROR
%token REG ACC TOP SIZE
%left AND OR NOT
%left PLUS MINUS
%left MUL DIV MOD
%left PARl PARr
%precedence NEG   /* negation--unary minus */
%% /* The grammar follows.  */
input:
  %empty
| input line
| error line { yyerrok;}
;
line:
  LINE
| exp LINE  { if(!errors){
              printf ("= %d\n> ",$1); acc = $1;
              errors = 0; 
            }
          }
| stack LINE { printf("> ");}
;
stack:
  PUSH register { top = Push(top,$2);}
| POP REG { top = Pop(top, &reg[$2]);}
| POP TOP { yyerror("ERROR: cannot pop to top"); errors = 0;YYERROR; }
| POP ACC { yyerror("ERROR: cannot pop to acc"); errors = 0;YYERROR; }
| POP SIZE { yyerror("ERROR: cannot change size of stack");errors = 0; YYERROR; }
| SHOW ACC { printf("%d\n",acc);}
| SHOW REG { printf("%d\n",reg[$2]);}
| SHOW TOP { if(top == NULL){
                yyerror("ERROR: Stack is empty"); errors = 0; YYERROR;
              }
              else{
                printf("%d\n",acc);
              }
            }            
| SHOW SIZE { printf("%d\n",size);}
| LOAD REG REG { loadOp(&reg[$2],$3);}
| LOAD REG TOP {if(top == NULL){
                  yyerror("ERROR: Stack is empty"); errors = 0; YYERROR;
                  }
                else{
                  loadOp(&reg[$2],$3);
                }
              }
;

register:
  REG         { $$ = reg[$1]; }
| ACC         { $$ = acc; }
| TOP         { $$ = top->data; }
| SIZE        { $$ = size; }
;
exp:
  NUM                { $$ = $1; }
| register           { $$ = $1; } 
| NOT exp            { $$ = ~$2; }
| exp AND exp         { $$ = $1 & $3; }
| exp OR exp         { $$ = $1 | $3; }
| exp PLUS exp        { $$ = $1 + $3; }
| exp MINUS exp        { $$ = $1 - $3; }
| exp MOD exp        { if($3 == 0){
                        yyerror("ERROR: divide by zero"); YYERROR;
                        }
                        else{
                          $$ = $1 % $3;
                        }
                     }
| exp MUL exp        { $$ = $1 * $3; }
| exp DIV exp        {if($3 == 0){
                        yyerror("ERROR: divide by zero"); YYERROR;
                        }
                        else{
                          $$ = $1 / $3;
                        }
                     }
| MINUS exp %prec NEG     { $$ = -$2; }
| PARl exp PARr           { $$ = $2; }
;
%%

node* Push(node *t, int value){
  node *q = (node*) malloc (sizeof(node)); 
  q->data = value;
  if(top == NULL){
    q->next = NULL;
    t = q;
  }
  else{
    q->next = t;
    t = q;
  }
  size += 1;
  return t;
}

node* Pop(node *t, int *element){
  if(t == NULL){
    yyerror("ERROR: Stack is empty");
    return NULL;
  }
  node *q = t;
  *element = q->data;
  if(t->next)
    t = t->next;
  else
    t = NULL;
  free(q);
  size -= 1;
  return t;
  
}
void loadOp(int *element, int value){
  *element = value;
}

// int yylex (void)
// {
//   int c;

//   /* Skip white space.  */
//   while ((c = getchar ()) == ' ' || c == '\t')
//     continue;
//   /* Process numbers.  */
//   if (c == '.' || isdigit (c))
//     {
//       ungetc (c, stdin);
//       scanf ("%lf", &yylval);
//       return NUM;
//     }
//   /* Return end-of-input.  */
//   if (c == EOF)
//     return 0;
//   /* Return a single char.  */
//   return c;
// }

void yyerror (char const *s)
{
  fprintf (stderr, "%s \n", s);
  printf("> ");
  errors++;
}

int main(void){
    printf("> "); 
    while(1){
      yyparse();
    }
    return 0; 
}