CC=gcc 
CFLAGS=-O2 -Wall -ggdb
TARGETS=fumble
TEST_FILE=test.txt

all: $(TARGETS)

%: ast.o %.lex.o %.tab.o
	$(CC) -o $@ $^

%.tab.o: %.tab.c %.tab.h
	$(CC) -c $(CFLAGS) $< -o $@

%.lex.o: %.lex.c %.tab.h
	$(CC) -c $(CFLAGS) $< -o $@

%.tab.c %.tab.h: %.y
	bison --defines -t -Wcounterexamples $^

%.lex.c: %.l
	flex -o $@ -d $^

ast.o: ast.c ast.h 
	$(CC) -c $(CFLAGS) $< -o $@

clean:
	rm -f *.lex.* *.tab.* *.o $(TARGETS)

test: all
	./fumble test.fumble

test_eval: all
	./fumble test_eval.fumble

test_string: all
	./fumble test_string.fumble 
test_preofx_operation: all
	./fumble
