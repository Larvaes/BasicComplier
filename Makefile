makefile:
	bison -d calc.y
	flex lex.l
	gcc calc.tab.c lex.yy.c -lfl -o calculator -lm