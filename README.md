# Java-Mini-Compiler
This is a mini-compiler for if-else and for loop constructs of Java, implemented using Flex and Bison. 
The data types implemented are int, and Boolean.
code.l is the lex file that recognizes the tokens.
codeSymbolTable.y is a Yacc file that contains the grammar, and semantic rules to build the symbol table
codeAST.y has semantic rules to print the abstract syntax tree for the grammar. 
codeinter.y has semantic rules for intermediate code generation, and statements are stored as quadruples. These quadruples are used to optimize the intermediate code. The optimization techniques implemented are Constant Folding and Constant propagation.

lex code.l
yacc -vd codeSymbolTable.y
gcc y.tab.c -o sym -ll -ly
yacc -vd codeAST.y
gcc y.tab.c -o ast -ll -ly
yacc -vd codeinter.y
gcc y.tab.c -o inter -ll -ly
./sym
./ast
./inter
