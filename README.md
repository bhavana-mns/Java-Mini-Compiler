# Java-Mini-Compiler
This is a mini-compiler for if-else and for loop constructs of Java, implemented using Flex and Bison. <br />
The data types implemented are int, and Boolean. <br />
code.l is the lex file that recognizes the tokens.<br />
codeSymbolTable.y is a Yacc file that contains the grammar, and semantic rules to build the symbol table <br />
codeAST.y has semantic rules to print the abstract syntax tree for the grammar.  <br />
codeinter.y has semantic rules for intermediate code generation, and statements are stored as quadruples. These quadruples are used to optimize the intermediate code. The optimization techniques implemented are Constant Folding and Constant propagation. <br />

lex code.l <br />
yacc -vd codeSymbolTable.y <br />
gcc y.tab.c -o sym -ll -ly <br />
yacc -vd codeAST.y <br />
gcc y.tab.c -o ast -ll -ly <br />
yacc -vd codeinter.y <br />
gcc y.tab.c -o inter -ll -ly <br />
./sym <br />
./ast <br />
./inter <br />
