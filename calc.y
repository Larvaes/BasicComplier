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
  node *top = NULL;
  //Functio, variable predefine and include headerfile
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
| input line                // starting symbol
| error LINE { yyerrok;}    // error handling with missing grammar 
;
line:
  LINE
| exp LINE  { printf ("= %d\n> ",$1); acc = $1; }     // numeric experssion
| stack LINE { printf ("> "); }                       // stack experssion
;
stack:
  PUSH register { top = Push(top,$2);}
| POP REG { if(top == NULL){                        // detect error if stack is empty
              yyerror("ERROR: Stack is empty");
              YYERROR;
            }
            else{
              top = Pop(top, &reg[$2]);
              }
          }
| POP TOP { yyerror("ERROR: cannot pop to top"); YYERROR; }       // detect error if try to chage top with pop
| POP ACC { yyerror("ERROR: cannot pop to acc"); YYERROR; }       // detect error if try to chage top with acc
| POP SIZE { yyerror("ERROR: cannot change size of stack"); YYERROR; }   // detect error if try to chage top with size 
| SHOW ACC { printf("= %d\n",acc); }          //show register, acc ,top of stack, size
| SHOW REG { printf("= %d\n",reg[$2]); }
| SHOW TOP { if(top == NULL){                                     // detect if try to print top while stack empty
                yyerror("ERROR: Stack is empty"); YYERROR;    
              }
              else{
                printf("= %d\n",acc);
              }
            }            
| SHOW SIZE { printf("= %d\n",size); }
| LOAD REG REG { loadOp(&reg[$2],reg[$3]); }                  // load value into register
| LOAD REG TOP {if(top == NULL){                              // detect if load value from top but top is empty 
                  yyerror("ERROR: Stack is empty"); YYERROR;
                  }
                else{
                  loadOp(&reg[$2],$3);
                }
              }
| LOAD REG ACC { loadOp(&reg[$2],$3); }
| LOAD REG SIZE { loadOp(&reg[$2],$3); }
| LOAD SIZE register { yyerror("ERROR: cannot change size of stack"); YYERROR; }    // detect if try to change top, acc, size
| LOAD TOP register { yyerror("ERROR: cannot change top of stack"); YYERROR; }
| LOAD ACC register { yyerror("ERROR: acc should not be changed"); YYERROR; }
;

register:
  REG         { $$ = reg[$1]; }                   // terminal symbol for each register
| ACC         { $$ = acc; }
| TOP         { $$ = top->data; }
| SIZE        { $$ = size; }
;
exp:                                              // grammar for number and experssion
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

node* Push(node *t, int value){                 // push function
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

node* Pop(node *t, int *element){           // pop function
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
void loadOp(int *element, int value){     // load function
  *element = value;
}

void yyerror (char const *s)              // error message
{
  fprintf (stderr, "%s \n", s);
  printf("> ");
}

int main(void){
    printf("> "); 
    while(1){
      yyparse();                        // strat parser
    }
    return 0; 
}