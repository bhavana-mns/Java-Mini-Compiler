%{
#include <stdio.h>
#include <stdlib.h>
#include<stdbool.h>
#include<string.h>
#include<math.h>
#include "lex.yy.c"
#include<ctype.h>




void yyerror (char const *);
//extern char yytext[];

struct OPT
{
	char op[10];
	char arg1[10];
	char arg2[10];
	char result[10];
};

struct OPT QIC[100];
struct OPT OPT[100];
int ind = 0;
int oind =0;

%}

%union 
{
        int number;
        char *string;
        bool *boo;
       
        
}

%token <number> NUM DECIMAL
%token <string> IDENTIFIER
%type<number> arithm_e
%type<number> assign_e
%type<string> ids1
%type<string> ids2
%type<string> ids3
%type<number> rel_e

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

S: compilation_unit	{printf("\nLine No. is %d  \n ACCEPTED\n\n\n\n",yylineno);  print_INT_CODE(); copy();  constant_folding(); print_OPT_CODE(); printf("\t\tAfter Constant Folding\n");  copy_prop(); print_OPT_CODE(); printf("\t\tAfter Copy propogation\n"); } //codegen_assign();}
 
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
class_stmt: PUBLIC CLASS class_name  OF main_method CF 
          ;
main_method: PUBLIC STATIC VOID MAIN OC STRING OS FS ARGS CC OF sl CF 
            ;

sl: sl s1
  |
  ;

s1: variable_declaration  SEMC   //{printf("Line No. is %d\n" , yylineno);}
    | expression  SEMC
    | if_stmt //{codegen();}
    |for_stmt //{codegen();}
    | SEMC
    ;

variable_declaration: dtypes
                    ;

dtypes: INT ids1 
        | FLOAT  ids2 
	| BOOLEAN  ids3 
        ;

ids1: IDENTIFIER { pushId($1);} EQ {push();} arithm_e {/*printStack();*/ codegen_assign();}	
   | ids1 COMMA IDENTIFIER	
   | IDENTIFIER //{push();}
  //| IDENTIFIER { pushId($1);} EQ {push();}rel_e { codegen_assign();}		
   ;

ids2: IDENTIFIER {/*printf("pushing identifier");*/ pushId($1);} EQ {push();} arithm_e {/*printStack();*/  codegen_assign();}    
   | ids2 COMMA IDENTIFIER	
   | IDENTIFIER	//{push();}		
   ;

ids3: IDENTIFIER {pushId($1);} EQ {push();} rel_e {/*printStack();*/  codegen_assign();}
   | ids3 COMMA IDENTIFIER	
   | IDENTIFIER	//{push();}		
   ;

expression:rel_e //{codegen();}
          | arithm_e //{codegen();}
       //   | assign_e //{codegen();}
          ;

rel_e: arithm_e LT{push();} arithm_e {codegen();}
          | arithm_e GT{push();} arithm_e {codegen();} 	//{$$ = ($1>$3);}
          | arithm_e LE{push();} arithm_e {codegen();}  	//{$$ = le($1,$3);}
          | arithm_e GE{push();} arithm_e {codegen();} 	//{$$ = ge($1,$3);}
          | arithm_e DEQ{push();} arithm_e {codegen();} 	//{$$ = eq($1,$3);}
          | arithm_e NE_OP{push();} arithm_e {codegen();} 	//{$$ = ne($1,$3);}
	  | IDENTIFIER{/*printf("pushing identifier");*/  pushId($1);} EQ{push();} rel_e {codegen_assign();}
          | TRUE1 {push();}			//{$$=$1;}
          | FALSE1 {push();}			//{$$=$1;}
	  | arithm_e
          ;


arithm_e:arithm_e ADD {push();} arithm_e{ /*printStack();*/ codegen();}
      |arithm_e SUB {push();} arithm_e{/* printStack();*/codegen();}
      |arithm_e MUL {push();} arithm_e{/* printStack();*/ codegen();}
      |arithm_e DIV {push();} arithm_e{ /*printStack();*/ codegen();}
      |{printf("\n");}IDENTIFIER {pushId($2);} EQ {push();} arithm_e  {/*printStack();*/ codegen_assign();}
      |IDENTIFIER { /*printf("pushing identifier");*/ pushId($1);} //{codegen();}
      |{printf("");}NUM {push();}//{codegen();}
     // |DECIMAL {push();}
      |IDENTIFIER {pushId($1);} INC_OP {push();} 
      |IDENTIFIER {pushId($1);} DEC_OP {push();} 
      //|INC_OP {push();} IDENTIFIER {pushId($3);} //{codegen();}
      //|DEC_OP {push();} IDENTIFIER {pushId($3);} //{codegen();}
      ;


//assign_e: IDENTIFIER {push();} EQ {push();} assign_e {codegen();}       	 ;


//if_stmt: IF OC rel_e CC OF sl %prec

if_stmt:	
	 IF OC rel_e CC {printf("\n");lab1();} OF sl CF {lab2();} ELSE OF sl CF {lab3();} 
	;

//if_stmt: IF OC rel_e  CC {printf(" ");lab1();} OF sl CF {lab2();}	;

/*if_stmt: IF OC rel_e  CC {lab1();} OF sl CF			
       | IF OC rel_e CC {lab1();} OF sl CF else_if_blocks {lab2();} 		
       //| IF OC rel_e {lab1();} CC OF sl CF else_if_blocks {lab2();}ELSE OF sl {lab3();} CF 
       ;

else_if_blocks : ELSE else_if_block 
               | else_if_blocks ELSE else_if_block 
               ;

else_if_block : IF OC rel_e  CC OF sl CF
          |  OF sl  CF
          ;*/

for_stmt: FOR OC for_args CC OF sl CF {lab4f(); } //exit(0);}
          ;

for_args: arg1{lab1f();} SEMC arg2{lab2f();} SEMC arg3 {lab3f();}
       ; 

arg1: variable_declaration //{codegen();}
       |expression //{codegen();}
       | 
       ;


arg2: rel_e //{codegen();}
     |
     ;

arg3:arithm_e //{codegen();}
     |
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
char st[100][10];
int top=0;
int i_ = 0;
char si[20];

char temp[2]="t";

int label[20];
int lnum=0;
int ltop=0;
int start=1;
char ss[20];
char l[1] = "L";

int main()
{
yyparse();
return 1;
}



void push()
{
//printf("pushing YYtext is %s\n",yytext);
strcpy(st[++top],yytext);
}


void pushId(char *name)
{
//printf("pushing yylval is %s\n",name);
strcpy(st[++top],name);
}



void codegen()
{
strcpy(temp,"t");
my_itoa(i_ , si);
strcat(temp, si);
strcpy(QIC[ind].result , temp);
strcpy(QIC[ind].op , st[top-1]);
strcpy(QIC[ind].arg1, st[top-2]);
strcpy(QIC[ind].arg2 , st[top]);
ind++;
printf("%s = %s %s %s\n",temp,st[top-2],st[top-1],st[top]);
top-=2;
strcpy(st[top],temp);
i_++;
}


void codegen_umin()
{
strcpy(temp,"t");


my_itoa(i_ , si);
strcat(temp, si);

printf("%s = -%s\n",temp,st[top]);
top--;
strcpy(st[top],temp);
i_++;
}

void codegen_assign()
{
strcpy(QIC[ind].result , st[top-2]);
strcpy(QIC[ind].op , "=");
strcpy(QIC[ind].arg1, st[top]);
strcpy(QIC[ind].arg2 , "");
ind++;

printf("%s = %s\n",st[top-2],st[top]);
top-=2;
}


void printStack()
{
int i = top;
printf("Printing Curr stack\n");
while(i>-1){
	printf("%s \n",st[i]);
	i = i-1;
}
}



void lab1()   //Create a new label - after a not condition
{
 lnum++;
 strcpy(temp,"t");


my_itoa(i_ , si);
strcat(temp, si);

strcpy(QIC[ind].result , temp);
strcpy(QIC[ind].op , "= not");
strcpy(QIC[ind].arg1, st[top]);
strcpy(QIC[ind].arg2 , "");
ind++;
 printf("%s = not %s\n",temp,st[top]);

my_itoa(lnum, ss);
strcpy(QIC[ind].result , strcat(ss,l));
strcpy(QIC[ind].op , "if goto");
strcpy(QIC[ind].arg1, temp);
strcpy(QIC[ind].arg2 , "");
ind++;

 printf("if %s goto L%d\n",temp,lnum);
 i_++;
 label[++ltop]=lnum;
}

void  lab2()  // Create an unconditional label
{
int x;
lnum++;
x=label[ltop--];

my_itoa(lnum ,ss );
strcpy(QIC[ind].result , strcat(ss , l ));
strcpy(QIC[ind].op , "goto");
strcpy(QIC[ind].arg1, "");
strcpy(QIC[ind].arg2 , "");
ind++;
printf("goto L%d\n",lnum);


my_itoa(lnum ,ss );
strcpy(QIC[ind].result , strcat(ss,l));
strcpy(QIC[ind].op , "");
strcpy(QIC[ind].arg1, "");
strcpy(QIC[ind].arg2 , "");
ind++;
printf("L%d: \n",x);
label[++ltop]=lnum;
}

lab3()   //Add created label
{
int y;
y=label[ltop--];

my_itoa(lnum ,ss );
strcpy(QIC[ind].result , strcat(ss,l));
strcpy(QIC[ind].op , "");
strcpy(QIC[ind].arg1, "");
strcpy(QIC[ind].arg2 , "");
ind++;
printf("L%d: \n",y);
}
 
lab1f()
{
	my_itoa(lnum ,ss );
	strcpy(QIC[ind].result , strcat(ss ,l ));
	strcpy(QIC[ind].op , "");
	strcpy(QIC[ind].arg1, "");
	strcpy(QIC[ind].arg2 , "");
	ind++;
    	printf("L%d: \n",lnum++);
}

lab2f()  // if with 2 labels 
{
    strcpy(temp,"t");
    
my_itoa(i_ , si);
strcat(temp, si);

strcpy(QIC[ind].result , temp);
strcpy(QIC[ind].op , "= not");
strcpy(QIC[ind].arg1, st[top]);
strcpy(QIC[ind].arg2 , "");
ind++;
 printf("%s = not %s\n",temp,st[top]);

my_itoa(lnum, ss);
strcpy(QIC[ind].result , strcat(ss, l));
strcpy(QIC[ind].op , "if goto");
strcpy(QIC[ind].arg1, temp);
strcpy(QIC[ind].arg2 , "");
ind++;

 printf("if %s goto L%d\n",temp,lnum);



    i_++;
    label[++ltop]=lnum;
    lnum++;


	my_itoa(lnum, ss);
	strcpy(QIC[ind].result , strcat(ss , l));
	strcpy(QIC[ind].op , "if goto");
	strcpy(QIC[ind].arg1, temp);
	strcpy(QIC[ind].arg2 , "");
	ind++;
	 printf("if %s goto L%d\n",temp,lnum);

	
	my_itoa(lnum ,ss );
strcpy(QIC[ind].result , strcat(ss,l ));
strcpy(QIC[ind].op , "goto");
strcpy(QIC[ind].arg1, "");
strcpy(QIC[ind].arg2 , "");
ind++;
    printf("goto L%d\n",lnum);
    label[++ltop]=lnum;


	my_itoa(++lnum ,ss );
	strcpy(QIC[ind].result , strcat(ss,l ));
	strcpy(QIC[ind].op , "");
	strcpy(QIC[ind].arg1, "");
	strcpy(QIC[ind].arg2 , "");
	ind++;
	printf("L%d: \n",lnum);
 }
lab3f()
{
    int x;
    x=label[ltop--];

	my_itoa(start ,ss );
strcpy(QIC[ind].result , strcat(ss,l));
strcpy(QIC[ind].op , "goto");
strcpy(QIC[ind].arg1, "");
strcpy(QIC[ind].arg2 , "");
ind++;
    printf("goto L%d \n",start);


	my_itoa(x ,ss );
	strcpy(QIC[ind].result , strcat(ss,l ));
	strcpy(QIC[ind].op , "");
	strcpy(QIC[ind].arg1, "");
	strcpy(QIC[ind].arg2 , "");
	ind++;
    printf("L%d: \n",x);
   
}

lab4f()
{
    int x;
    x=label[ltop--];


	my_itoa(lnum ,ss );
strcpy(QIC[ind].result , strcat(ss,l));
strcpy(QIC[ind].op , "goto");
strcpy(QIC[ind].arg1, "");
strcpy(QIC[ind].arg2 , "");
ind++;
    printf("goto L%d \n",lnum);   


	my_itoa(x ,ss );
	strcpy(QIC[ind].result , strcat(ss,l));
	strcpy(QIC[ind].op , "");
	strcpy(QIC[ind].arg1, "");
	strcpy(QIC[ind].arg2 , "");
	ind++;

    printf("L%d: \n",x);
}

void my_itoa(int num, char temp1[20])
{
	sprintf(temp1,"%d",num);
	//return temp1;
}







void print_INT_CODE()
{
	int i;
	printf("the value of ind %d\n",ind);
	printf("\n--------------------------------------------------------\n");
	printf("\nINTERMEDIATE CODE\n\n");
	printf("--------------------------------------------------------\n");
	printf("--------------------------------------------------------\n");
	printf("\n%17s%10s%10s%10s%10s","post","op","arg1","arg2","result\n");
	printf("--------------------------------------------------------\n");
	
	for(i=0;i<ind;i++)
	{
		printf("\n%15d%10s%10s%10s%10s", i,QIC[i].op, QIC[i].arg1,QIC[i].arg2,QIC[i].result);
	}
	printf("\n\t\t -----------------------");
	printf("\n");
	return 0;
}

void print_OPT_CODE()
{
	int i;
	printf("the value of ind %d\n",ind);
	printf("\n--------------------------------------------------------\n");
	printf("\nOPTIMIZED INTERMEDIATE CODE\n\n");
	printf("--------------------------------------------------------\n");
	printf("--------------------------------------------------------\n");
	printf("\n%17s%10s%10s%10s%10s","post","op","arg1","arg2","result\n");
	printf("--------------------------------------------------------\n");
	
	for(i=0;i<oind;i++)
	{
		printf("\n%15d%10s%10s%10s%10s", i,OPT[i].op, OPT[i].arg1,OPT[i].arg2,OPT[i].result);
	}
	printf("\n\t\t -----------------------");
	printf("\n");
	return 0;
}













int counter =0 ;

void constant_folding()
{
	//printf("inside \n");	
	int i=0;
	int flag=0;
	int temp;
	char temp1[10];
	for(i=0;i<ind;i++)
	{
		char s[100];
		char s1[100];
		strcpy(s,OPT[i].arg1);	
		strcpy(s1,OPT[i].arg2);
		flag=isDigit(s);
		if(flag==1)
		{
			continue;
			//printf("fail\n");
		}
		else
		{
			flag=isDigit(s1);
			if(flag==1)
			{
				continue;
			}
			else
			{
				//printf("both are number %d\n",i);
				char a= OPT[i].op[0];
				//printf("a value is %c\n",a);
				switch(a)
				{
					case '+': 
				//		  printf("inside the case %d \n",i);
						  temp = atoi(s) + atoi(s1);
				//		  printf("value of temp %d\n",temp);
						  my_itoa(temp,temp1);
				//		  printf("value of temp1 %s\n",temp1);
						  strcpy(OPT[i].arg1,temp1);
					          strcpy(OPT[i].op,"=");
						  strcpy(OPT[i].arg2,"");
						  break;
					case '-': 
				//		  printf("inside the case %d \n",i);
						  temp = atoi(s) - atoi(s1);
				//		  printf("value of temp %d\n",temp);
						  my_itoa(temp,temp1);
				//		  printf("value of temp1 %s\n",temp1);
						  strcpy(OPT[i].arg1,temp1);
					          strcpy(OPT[i].op,"=");
						  strcpy(OPT[i].arg2,"");
						  break;
				}
				char b= OPT[i+1].op[0];
				//printf("hello1 %c\n",b);
		
				if(b=='=')
				{
					 strcpy(OPT[i].result,OPT[i+1].result);
					 int j=0;
                  			 for(j=i+1;j<ind;j++)
					{
							OPT[j]=OPT[j+1];
					}
					ind--;
					//tIndex--;
					counter+=1;
					
				}
				else
				{
					int k;
					strcpy(OPT[i+1].arg1,OPT[i].arg1);
					for(k=i+1;k<ind;k++)
					{
							OPT[k-1]=OPT[k];
					}
					ind--;
					//tIndex--;
					i=i-1;
					counter+=1;
					
				}
		
			}
		}		
		flag=0;
		//printf("so m3 \n");	
	}
}


int isDigit(char t[100])
{
	//printf("inside digit %s\n",t);
	if(t!=NULL)
	{
		int check=atoi(t);
		//printf("value of check %s for %d\n",t,check);
		if(check==0)
			return 1;
		else
			return 0;
	}
	return 1;
}




void copy()
{
  oind=ind;
  int i=0;
  for(i=0;i<ind;i++)
  {
	OPT[i] = QIC[i];
  }
}






struct mappping{
	char ext[100];
	char ori[100];
	}map[100];


void copy_prop()
{
	int i=0;
	int k =0;
	int flag=0;
	int temp;
	char temp1[10];
	char ext1[100];
	char ext2[100];
	ind = oind;
	int remove[100] ;
	int cnt = 0;


	for(i=0;i<ind;i++)
	{
		
		char a= OPT[i].op[0];
		
		if(a =='=')
		{
		strcpy(map[k].ext,OPT[i].result);	
		strcpy(map[k].ori,OPT[i].arg1);
		k++;
		}
		
	}




	for(i=0;i<ind;i++)
	{
		char a= OPT[i].op[0];
		

		strcpy(ext1,OPT[i].arg1);
		int check = isDigit(ext1);
		//printf("%s , a is %c Is digit %d \n" ,ext1 , a ,  check);
		int ach = strncmp(ext1, "t" , 1) ; 
		if(check == 1 && a=='=' &&  ach!=0 )
		{	
			remove[cnt] = i;
			cnt++;
		}

		else{
			strcpy(ext1,OPT[i].arg1);	
			strcpy(ext2,OPT[i].arg2);
			for(int j=0;j<k;j++)
			{
			if(strcmp(ext1, map[j].ext)==0)
				strcpy(OPT[i].arg1 , map[j].ori);
			if(strcmp(ext2, map[j].ext)==0)
				strcpy(OPT[i].arg2 , map[j].ori);
			}
	     	   }
	}


	for(int m=0; m<cnt ;m++)
	{	
		printf("%d \n" , remove[m]);		
		for (int x = remove[m]-m ; x <  ind - 1; x++)
		{
			OPT[x] = OPT[x + 1];
			
		}
		oind = oind -1;
	}

}





















