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



#include "stack.h"

// Stack erstellen
Stack* stack_create(size_t initialCapacity) {
    Stack *s = (Stack*)malloc(sizeof(Stack));
    if (!s) {
        fprintf(stderr, "Memory allocation failed for stack\n");
        return NULL;
    }
    s->items = (void**)malloc(initialCapacity * sizeof(void*));
    if (!s->items) {
        fprintf(stderr, "Memory allocation failed for stack items\n");
        free(s);
        return NULL;
    }
    s->top = -1;
    s->capacity = initialCapacity;
    return s;
}

// Stack zerstören
void stack_destroy(Stack *s) {
    if (s) {
        free(s->items);
        free(s);
    }
}

// Element hinzufügen
bool stack_push(Stack *s, void *item) {
    if (!s) return false;
    if (s->top + 1 == s->capacity) {
        // Speicher erweitern
        s->capacity *= 2;
        void **newItems = (void**)realloc(s->items, s->capacity * sizeof(void*));
        if (!newItems) {
            fprintf(stderr, "Memory reallocation failed\n");
            return false;
        }
        s->items = newItems;
    }
    s->items[++(s->top)] = item;
    return true;
}

// Element entfernen
void* stack_pop(Stack *s) {
    if (!s || stack_is_empty(s)) return NULL;
    return s->items[(s->top)--];
}

// Top-Element abrufen
void* stack_peek(Stack *s) {
    if (!s || stack_is_empty(s)) return NULL;
    return s->items[s->top];
}

// Prüfen, ob der Stack leer ist
bool stack_is_empty(Stack *s) {
    return s && s->top == -1;
}

// Aktuelle Größe des Stacks
int stack_size(Stack *s) {
    return s ? s->top + 1 : 0;
}
