%{
#include <stdio.h>
#include<stdbool.h>
#include"lex.yy.c"
#include<string.h>

void PSymTable();
int mapping(char *);
void yyerror (char const *);
int func(int, int, int);

char errMess[55] = "Error";
extern int yylineno;
int xpos =-1;
int idx =-1; // A global variable to hold the number of items already in the symbol table
struct SymTable
{
    char idName[50];
    int value;
    int type;  //0-int , 1-float , 2-true , 3-false
    int line_no;
    int scope;
};

struct SymTable st[50];




%}

%union
{
    	int number;
    	char *string;
//    	bool *boo;
   	 
}

%token <number> NUM  DECIMAL
%token <string> IDENTIFIER
//%token <boo> NUM
%type<number> arithm_e

%type<string> ids1
%type<string> ids2
%type<string> ids3
%type<number> rel_e
//%type<boo> arithm_e


%token CONSTANT STRING_LITERAL
%token INC_OP DEC_OP LE GE EQ NE_OP DEQ
%token AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD ADD_ASSIGN
%token SUB_ASSIGN
%token TYPEDEF STATIC
%token CHAR INT FLOAT CONST VOID
%token IF ELSE FOR GOTO CONTINUE BREAK RETURN
%token TRUE1 FALSE1 BOOLEAN
%token IMPORT CLASS PACKAGE MAIN STRING ARGS PUBLIC SOP
%token OC CC OF CF OS FS
%token ADD SUB MUL DIV LT GT COMMA COL DOT
%token BIT_AND NOT EXP BIT_OR QUE SEMC



%nonassoc EQ
%left ADD SUB
%left MUL DIV
%right LT GT  NE LE GE DEQ

%%
S: compilation_unit    {PSymTable(); printf("\n ACCEPTED\n");}
 // | S compilation_unit
  ;
compilation_unit: package_statement import_statement class_stmt
             	;
package_statement: PACKAGE IDENTIFIER SEMC
             	;
import_statement: IMPORT IDENTIFIER  DOT MUL SEMC
   		  | IMPORT class_name SEMC
                     	| IMPORT MUL SEMC
                     	|
   		  ;

class_name: IDENTIFIER
    	;
class_stmt: PUBLIC CLASS class_name OF main_method CF
      	;
main_method: PUBLIC STATIC VOID MAIN OC STRING OS FS ARGS CC OF sl CF
        	;

sl: sl s1
  |
  ;

s1: variable_declaration SEMC   //{printf("Line No. is %d\n" , yylineno);}
	| expression SEMC   	 
	| if_stmt
	|for_stmt
	| SEMC
	;

variable_declaration: dtypes
                	;

dtypes: INT ids1
    	| FLOAT  ids2
    | BOOLEAN  ids3
    	;

ids1: IDENTIFIER EQ arithm_e    {if(mapping($1)==-1){idx++; strcpy(st[idx].idName,$1); st[idx].type =0; st[idx].value = $3;} }
   | ids1 COMMA IDENTIFIER    {if(mapping($3)==-1) {idx++; strcpy(st[idx].idName,$3);  st[idx].type =0; } else {yyerror(errMess);} }
   | IDENTIFIER    	 {if(mapping($1)==-1) {idx++; strcpy(st[idx].idName,$1); st[idx].type =0; } }
   | IDENTIFIER EQ rel_e    {xpos = mapping($1);  if(xpos==-1) {idx++; strcpy(st[idx].idName,$1); st[idx].type =3; st[idx].value = $3;} else { st[xpos].value = $3; } }
   ;

ids2: IDENTIFIER EQ arithm_e	{if(mapping($1)==-1) {idx++; strcpy(st[idx].idName,$1); st[idx].type =1; st[idx].value = $3;} }
   | ids2 COMMA IDENTIFIER    {if(mapping($3)==-1) { idx++; strcpy(st[idx].idName,$3);  st[idx].type =1; } else {yyerror(errMess);}}
   | IDENTIFIER   		 {if(mapping($1)==-1) {idx++; strcpy(st[idx].idName,$1);  st[idx].type =1; }}
   ;

ids3: IDENTIFIER EQ rel_e    {if(mapping($1)==-1) {idx++; strcpy(st[idx].idName,$1); st[idx].type =3; st[idx].value = $3;} else { st[xpos].value = $3; } }
  // | ids3 COMMA IDENTIFIER    {if(mapping($3)==-1) {idx++; strcpy(st[idx].idName,$3);  st[idx].type =3; } else {printf(yyerror(errMess));} }
   | IDENTIFIER    	 {if(mapping($1)==-1) {idx++; strcpy(st[idx].idName,$1); st[idx].type =3; } }
   ;

expression: arithm_e
         | rel_e
      	;

rel_e: arithm_e LT arithm_e   	 {$$ = func($1,$3,1);}
      	| arithm_e GT arithm_e 	 {$$ = func($1,$3,2);}
      	| arithm_e LE arithm_e 	 {$$ = func($1,$3,3);}
      	| arithm_e GE arithm_e 	 {$$ = func($1,$3,4);}
      	| arithm_e DEQ arithm_e     {$$ = func($1,$3,5);}
      	| arithm_e NE_OP arithm_e     {$$ = func($1,$3,6);}
      | IDENTIFIER EQ rel_e     {xpos = mapping($1);if(xpos!=-1) { st[xpos].value = $3; } else { yyerror(errMess);}}
      	| TRUE1   		 {$$=1;}
      	| FALSE1   		 {$$=0;}
      	;

arithm_e: arithm_e MUL arithm_e   	 {$$ = $1 * $3;}
     | arithm_e DIV arithm_e    {$$ = $1 / $3;}
     | arithm_e ADD arithm_e    { $$ = $1 + $3;}
     | arithm_e SUB arithm_e    {$$ = $1 - $3;}
     | IDENTIFIER   		{xpos = mapping($1); if(xpos!=-1) { $$ = st[xpos].value; } else {yyerror(errMess);} }
     | NUM   			 {$$ =  $1; }
    // | DECIMAL   		 {$$ =  $1; }
     | IDENTIFIER INC_OP   	 {xpos = mapping($1); $$=st[xpos].value+1;}
     | IDENTIFIER DEC_OP   	 {xpos = mapping($1); $$=st[xpos].value-1;}
     | INC_OP IDENTIFIER    	 {xpos = mapping($2); $$=st[xpos].value+1;}
     | DEC_OP IDENTIFIER    	 {xpos = mapping($2); $$=st[xpos].value-1;}
     | IDENTIFIER EQ arithm_e    {xpos = mapping($1); if(xpos!=-1) { st[xpos].value = $3; } else {yyerror(errMess);}}
	//| rel_e			{$$ = $1;}     
	;

//assign_e: IDENTIFIER EQ assign_e    	{xpos = mapping($1); if(xpos!=-1) { st[xpos].value = $3; } else {printf("*******************IN assign_e");yyerror(errMess);}}
     ;


if_stmt: IF OC rel_e CC OF sl CF   		 
   	| IF OC rel_e CC OF sl CF else_if_blocks
    //OF sl CF    	 
   	//| IF OC rel_e CC OF sl CF else_if_blocks ELSE OF sl CF
   	;

else_if_blocks :  ELSE else_if_block
           	| else_if_blocks  ELSE else_if_block
           	;

else_if_block : IF OC rel_e CC OF sl CF
      	|  OF sl CF
          	;

for_stmt: FOR OC for_args CC OF sl CF   
    	;

for_args: arg1 SEMC arg2 SEMC arg3
   	;

arg1: variable_declaration
   	|expression
   	|
   	;


arg2: rel_e
 	|
 	;

arg3:arithm_e
 	|
 	;



%%



void yyerror (char const *s)
{
fprintf (stderr, "%s\n", s);
  printf("Error occured at  Line No.  %d\n" , yylineno);
 //	printf("Error at position : %d\n" , yyltype);
 //printf("more : %s" , yymore);
 // printf("less: %s" , yyless);
   printf("Error after : %s\n" , yytext);
 //exit(0);
}


int main()
{
yyparse();
return 1;
}


int mapping(char *name)
{
    int j=-1;
    for(j=0;j<idx+1;j++)
    {
   	// printf("Found for:%s %s %d\n",name , st[j].idName ,  j);   	 
   	 if(strcmp(name, st[j].idName)==0)
   	 {    
   		 //printf("Returning %d " , j);   		 
   		 return j;
   	 }
    }
return -1;
}


void PSymTable()
{
    int j=-1;
    printf("\nType\tName\tValue\t\n");
    for(j=0;j<=idx;j++)
    {    
	if(st[j].type==0)
			printf("int\t");
		else
			printf("bool\t");
   		 //printf("Found for:%d\n", j);
   		// printf("Name is :%s , ", st[j].idName);
   		 //printf("Value is :%d , ", st[j].value);
   		 //printf("Type is :%d\n", st[j].type);
		printf("%s\t%d\t\n",st[j].idName,st[j].value);
		
    }
}


int func(int a, int b, int k )
{
//printf("%d %d \n" , a , b);
switch(k)
{
case 1: if (a<b)
    	return 1;
    	else
    	return 0;
    	break;

case 2: return (a>b);
     	break;
     	 
case 3: return (a<=b);
     	break;
     	 
case 4: return (a>=b);
     	break;
     	 
case 5: return (a==b);
     	break;
     	 
case 6: return (a!=b);
     	break;
}
}     	 
     	 














