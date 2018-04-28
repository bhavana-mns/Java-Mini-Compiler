%{
#include <stdio.h>
#include "y.tab.h"
%}

%option yylineno
digit	[0-9]
letter	[a-zA-Z_]

%x COMMENTS
%%
[ \t\n]		        ;
"//".*			;
"/*"			{BEGIN(COMMENTS);}
<COMMENTS>"*/"		{;BEGIN(INITIAL);}
<COMMENTS>.		;
"break"			 return(BREAK); 
"char"			return(CHAR);
"const"			return(CONST);
"continue"		return(CONTINUE);
"else"			return(ELSE);
"float"			return(FLOAT);
"true"			return(TRUE1);
"false"			return(FALSE1);
"Boolean"		return(BOOLEAN);
"for"            	return(FOR);
"if"            	 return(IF); 
"int"            	  return(INT);  

"return"        	return(RETURN);
"static"        	return(STATIC);
"void"            	return(VOID);
"import"		return(IMPORT);
"class"			return(CLASS);
"package"		return(PACKAGE);
"main"			return(MAIN);
"String"		return(STRING);
"public"		return(PUBLIC);
"System.out.print"	return(SOP);
"args"			return(ARGS);

{letter}({letter}|{digit})*	{yylval.string=strdup(yytext); return (IDENTIFIER) ;}
{digit}+		{yylval.number=atoi(yytext); return NUM; }

({digit}*\.{digit}+)     {yylval.number=atof(yytext); return DECIMAL; }
letter?'(\\.|[^\\'\n])+'	return(CONSTANT);
L?\"(\\.|[^\\"\n])*\"		return(STRING_LITERAL);


"+="            	return(ADD_ASSIGN);
"-="            	return(SUB_ASSIGN);
"*="           		return(MUL_ASSIGN); 
"/="            	return(DIV_ASSIGN); 
"++"            	return(INC_OP);
"--"               	return(DEC_OP); 
"&&"               	return(AND_OP); 
"||"            	return(OR_OP); 
"!="            	return(NE_OP); 
"("		 	return(OC);
")"		 	return(CC);
"{" 		 	return(OF);
"}" 		 	return(CF);
"[" 		 	return(OS);
"]"		 	return(FS);
"+"		 	return(ADD);
"*" 		 	return(MUL);
"/"	         	return(DIV);
"-"		 	return(SUB);
"<"		 	return(LT);
">" 		 	return(GT);
","         	 	return(COMMA);
"<="		 	return(LE);
">="		 	return(GE);
"=="		 	return(DEQ);
":"              	return(COL);
"="            		return(EQ); 
"."            		return(DOT); 
"&"            		return(BIT_AND); 
"!"            		return(NOT); 
"%"            		return(MOD); 
"^"            		return(EXP); 
"|"           		return(BIT_OR); 
"?"            		return(QUE); 
";"            		return(SEMC); 
.            		;
%%

