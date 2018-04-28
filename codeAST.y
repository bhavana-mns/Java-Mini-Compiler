//https://github.com/yihui-he/c-compiler/blob/master/q2.y


%{
#include <stdio.h>
#include "lex.yy.c"
#include<string.h>

void yyerror (char const *);


extern int yylineno;
char *dummy;
  typedef struct node
  {
    struct node *left;
    struct node *right;
    struct node *another;
    char *token;
  } node;

  node *mknode(node *left, node *right, node *another, char *token);
  void printtree(node *tree);

//#define YYSTYPE struct node *
%}

%union 
{
        int number;
        char *string;
        //bool *boo;
	struct node * nd_type;      
}

%token <number> NUM  DECIMAL
%token <string> IDENTIFIER
//%token <boo> BOOLEAN

%type<nd_type> rel_e arithm_e if_stmt else_if_blocks else_if_block for_stmt for_args sl s1 arg1 arg2 arg3 expression idd dtypes variable_declaration
%type<nd_type> compilation_unit class_stmt main_method
%type<number> assign_e
%type<string> ids1 ids2 ids3


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


%right EQ
%left ADD SUB
%left MUL DIV
%right LT GT NE LE GE DEQ

%%
S: compilation_unit	{ printtree($1); printf(" \n ACCEPTED\n");}
  | S compilation_unit
  ;

compilation_unit: package_statement import_statement class_stmt	{$$ = $3;}
                 ;
package_statement: PACKAGE idd SEMC
                 ;
import_statement: IMPORT idd  DOT MUL SEMC 
			 | IMPORT class_name SEMC 
                         | IMPORT MUL SEMC
                         |
			 ;

class_name: IDENTIFIER 
        ;
class_stmt: PUBLIC CLASS class_name OF main_method CF 		  	{$$ = $5;}
          ;
main_method: PUBLIC STATIC VOID MAIN OC STRING OS FS ARGS CC OF sl CF {$$ = $12;}
            ;

sl: sl s1		{$$ = mknode($1,$2,0,"stmt");}
  |			{$$ = mknode(0,0,0,"NULL");}
  ;

s1: variable_declaration SEMC   { $$=$1 ;} //printf("Line No. is %d\n" , yylineno);}
    | expression SEMC		{$$ = $1;}
    | if_stmt			{$$ = $1;} //printf("IF DONE S1");}
    |for_stmt 			{$$ = $1;}
    | SEMC                      {$$ = mknode(0,0,0,"SEMC");}
    ;

variable_declaration: dtypes 	{ $$ = $1;}
                    ;

dtypes: INT ids1		{$$ = $2;}
        | FLOAT  ids2		{$$ = $2;}
	| BOOLEAN  ids3		{$$ = $2;}
        ;

ids1: idd EQ arithm_e		{$$ = mknode($1,$3,0,"=");}
   | ids1 COMMA idd	
   | idd 			{$$ = $1;}
  | idd EQ rel_e  		{$$ = mknode($1,$3,0,"=");}
   ;

ids2: idd EQ arithm_e    	{$$ = mknode($1,$3,0,"=");}
   | ids2 COMMA idd	
   | idd			{$$ = $1;}
   ;

ids3: ids3 EQ idd               {$$ = mknode($1,$3,0,"=");}
   | ids3 EQ rel_e              {$$ = mknode($1,$3,0,"=");}
   | ids3 COMMA idd	 
   | idd			{$$ = $1;}
   ;

expression:rel_e		{$$ = $1;}
          | arithm_e		{$$ = $1;}
          ;

rel_e: arithm_e LT arithm_e		{$$ = mknode($1, $3,0, "<");}
          | arithm_e GT arithm_e	{$$ = mknode($1, $3,0, ">");}
          | arithm_e LE arithm_e	{$$ = mknode($1, $3, 0,"<=");}
          | arithm_e GE arithm_e	{$$ = mknode($1, $3,0, ">=");}
          | arithm_e DEQ arithm_e	{$$ = mknode($1, $3,0, "==");}
          | arithm_e NE_OP arithm_e	{$$ = mknode($1, $3, 0,"!=");}
	  | idd EQ rel_e		{$$ = mknode($1, $3,0, "=");}
          | TRUE1			{$$ = mknode(0,0,0,"true");}
          | FALSE1			{$$ = mknode(0,0,0,"false");}
          ;

arithm_e: arithm_e MUL arithm_e		 {$$ = mknode($1, $3,0, "*");}
	 | arithm_e DIV arithm_e	 {$$ = mknode($1, $3,0, "/");}
	 | arithm_e ADD arithm_e	 {$$ = mknode($1, $3, 0,"+");}
	 | arithm_e SUB arithm_e	 {$$ = mknode($1, $3, 0,"-");}
	 | idd			 	{$$ = $1;}
	 | NUM				{$$ = mknode(0,0,0,yytext);}
	// | DECIMAL			{$$ =  $1; }
	 | idd INC_OP		{$$ = mknode($1,0,0,"++");}
	 | idd DEC_OP		{$$ = mknode($1,0,0,"--");}
	 | INC_OP idd 		{$$ = mknode(0,$2,0,"++");}
	 | DEC_OP idd 		{$$ = mknode(0,$2,0,"--");}
	 | idd EQ arithm_e       {$$ = mknode($1,$3,0,"=");}
	 ;

idd:IDENTIFIER 	{char *name = $1 ; $$ = mknode(0,0,0,name);}
   ;




if_stmt: IF OC rel_e CC OF sl CF			{$$ = mknode($3,$6,0,"IF");} //printf("IF DONE");}			
       | IF OC rel_e CC OF sl CF else_if_blocks         {$$ = mknode($3,$6,$8,"IF_ELSE_IF");}
       ;

else_if_blocks :  ELSE else_if_block         		{$$ = $2;}    
               | else_if_blocks ELSE else_if_block      {$$ = mknode($1,$3,0,"ELSE_IF_BLOCKS");}	
               ;	

else_if_block : IF OC rel_e CC OF sl CF			{$$ = mknode($3,$6,0,"ELSE_IF");}
	      |  OF sl CF				{$$ = mknode(0,$2,0,"ELSE");}
              ;

for_stmt: FOR OC for_args CC OF sl CF			{$$ = mknode($3,$6,0,"FOR");}
        ;

for_args: arg1 SEMC arg2 SEMC arg3                      {$$ = mknode($1,$3,$5,"FOR_ARGS");}
       ;

arg1: variable_declaration                              {$$=$1;}
       |ids1                                            {$$=$1;}
       | 						{$$ = mknode(0,0,0,"NULL");}
       ;


arg2: rel_e                                             {$$=$1;}
     |							{$$ = mknode(0,0,0,"NULL");}
     ;

arg3:arithm_e                                           {$$=$1;}
     |							{$$ = mknode(0,0,0,"NULL");}
     ;


%%

void yyerror (char const *s)
{
fprintf (stderr, "%s\n", s);
  printf("Error occured at  Line No.  %d\n" , yylineno);
 //    printf("Error at position : %d\n" , yyltype);
 //printf("more : %s" , yymore);
 // printf("less: %s" , yyless);
   printf("Error after : %s\n" , yytext);
 exit(0); 
}


int main()
{
yyparse();
return 1;
}



node *mknode(node *left, node *right, node* another, char *token)
{
   //printf("Making NODE");
  /* malloc the node */
  node *newnode = (node *)malloc(sizeof(node));
  char *newstr = (char *)malloc(strlen(token)+1);
  strcpy(newstr, token);
  newnode->left = left;
  newnode->right = right;
  newnode->another = another;
  newnode->token = newstr;
  return(newnode);
}

void printtree(node *tree)
{
  //printf("Printing tree");

  if (tree->left || tree->right || tree->another)
    printf("(");

  printf(" %s ", tree->token);

  if (tree->left)
    printtree(tree->left);
  if (tree->right)
    printtree(tree->right);
  if (tree->another)
    printtree(tree->another);

  if (tree->left || tree->right || tree->another)
    printf(")");
}













