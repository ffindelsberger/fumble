#ifndef STACK_H
#define STACK_H

#include <stdbool.h>
#include <cstddef>
#include <cstdint>

// Stack-Definition
typedef struct {
    void **items;     
    int top;          // Aktueller Index des Top-Elements
    int capacity;     // Aktuelle Kapazität des Stacks
} Stack;


Stack* stack_create(size_t initialCapacity);
void stack_destroy(Stack *s);
bool stack_push(Stack *s, void *item);
void* stack_pop(Stack *s);
void* stack_peek(Stack *s);
bool stack_is_empty(Stack *s);
int stack_size(Stack *s);

#endif // STACK_H
