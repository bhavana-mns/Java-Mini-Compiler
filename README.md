# Java-Mini-Compiler
This is a mini-compiler for if-else and for loop constructs of Java, implemented using Flex and Bison. 
The data types implemented are int, and Boolean.
code.l is the lex file that recognizes the tokens.
codeSymbolTable.y is a Yacc file that contains the grammar, and semantic rules to build the symbol table
codeAST.y has semantic rules to print the abstract syntax tree for the grammar. 

