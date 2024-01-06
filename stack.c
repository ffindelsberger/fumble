#include <stdio.h>
#include <stdlib.h>
#include <time.h>

typedef int val_t;
typedef struct stack {
  val_t *val;
  int size;
} stack;

stack *s_new(void) { return calloc(1, sizeof(stack_t)); }

void s_push(stack *s, val_t elem) {
  s->val = realloc(s->val, (s->size + 1) * sizeof elem);
  s->val[s->size++] = elem;
}

val_t s_pop(stack *s) { return s->val[--s->size]; }

int s_isempty(stack *s) { return s->size == 0; }

int test(void) {
  srand(time(NULL));

  stack *s = s_new();

  s_push(s, 3);
  s_push(s, 1);
  s_push(s, 3);
  s_push(s, 3);
  s_push(s, 7);

  for (int i = 0; i < 3; i++)
    printf("%d\n", s_pop(s));

  s_push(s, 2);
  s_push(s, 4);
  s_push(s, 8);

  for (int i = 0; i < 5; i++)
    printf("%d\n", s_pop(s));

  int amount = random() % 6 + 5;
  for (int i = 0; i < amount; i++)
    s_push(s, random() % 100 + 1);

  while (!s_isempty(s))
    printf("%d\n", s_pop(s));

  exit(EXIT_SUCCESS);
}
