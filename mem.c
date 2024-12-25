#include "ast.h"
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

data var_declare_global(char *id, data val);
data var_declare(char *id, data val);
data var_set(char *id, data val);
data var_get(char *id);
void var_enter_block(void);
void var_leave_block(void);
void var_enter_function(void);
void var_leave_function(void);
void var_dump(void);

typedef struct {
  char *id;
  data val;
  int flags;
} stackval_t;

typedef struct {
  stackval_t *vals;
  int size;
} stack;

static stack vars, globals;

void s_push(stack *stack, stackval_t val) {
  stack->vals = realloc(stack->vals, (stack->size + 1) * sizeof(stackval_t));
  assert(stack->vals != NULL);
  stack->vals[stack->size++] = val;
}

#define VAR_BORDER_FUNC 2
#define VAR_BORDER_BLOCK 1

static stackval_t *var_lookup(char *id, int border) {
  for (int i = vars.size - 1; i >= 0; i--) {
    if (vars.vals[i].flags >= border)
      break;
    if (strcmp(vars.vals[i].id, id) == 0)
      return &vars.vals[i];
  }

  if (border == VAR_BORDER_BLOCK)
    return NULL;

  for (int i = globals.size - 1; i >= 0; i--) {
    if (strcmp(globals.vals[i].id, id) == 0)
      return &globals.vals[i];
  }

  return NULL;
}

data var_declare_global(char *id, data val) {
  stackval_t *s = var_lookup(id, 0);
  if (s) {
    // Handle multiple declaration in same block
    // Here: Just ignore the new declaration, set new value
    s->val = val;
  } else {
    s_push(&globals, (stackval_t){.val = val, .id = strdup(id)});
  }

  return val;
}

data var_declare(char *id, data val) {
  stackval_t *s = var_lookup(id, VAR_BORDER_BLOCK);
  if (s) {
    // Handle multiple declaration in same block
    // Here: Just ignore the new declaration, set new value
    s->val = val;
  } else {
    s_push(&vars, (stackval_t){.val = val, .id = strdup(id)});
  }

  return val;
}

data var_set(char *id, data val) {
  stackval_t *s = var_lookup(id, VAR_BORDER_FUNC);
  if (s)
    s->val = val;
  else {
    // Handle usage of undeclared variable
    // Here: implicitly declare variable
    var_declare(id, val);
  }

  return val;
}

data var_get(char *id) {
  stackval_t *s = var_lookup(id, VAR_BORDER_FUNC);
  if (s)
    return s->val;
  else {
    // Handle usage of undeclared variable
    // Here: implicitly declare variable
    // var_declare(id, 0);

    return var_declare(id, 0);
  }
}

void var_enter_block(void) {
  s_push(&vars, (stackval_t){.flags = VAR_BORDER_BLOCK, .id = ""});
}

void var_leave_block(void) {
  int i;
  for (i = vars.size - 1; i >= 0; i--) {
    if (vars.vals[i].flags == VAR_BORDER_BLOCK)
      break;
  }
  vars.size = i;
}

void var_enter_function(void) {
  s_push(&vars, (stackval_t){.flags = VAR_BORDER_FUNC, .id = ""});
}

void var_leave_function(void) {
  int i;
  for (i = vars.size - 1; i >= 0; i--) {
    if (vars.vals[i].flags == VAR_BORDER_FUNC)
      break;
  }
  vars.size = i;
}

void var_dump(void) {
  printf("-- TOP --\n");
  for (int i = vars.size - 1; i >= 0; i--) {
    if (vars.vals[i].flags == VAR_BORDER_FUNC) {
      printf("FUNCTION\n");
    } else if (vars.vals[i].flags == VAR_BORDER_BLOCK) {
      printf("BLOCK\n");
    } else {
      printf("%s : %d\n", vars.vals[i].id, vars.vals[i].val);
    }
  }
  printf("-- BOTTOM --\n");
  for (int i = globals.size - 1; i >= 0; i--) {
    printf("%s : %d (global)\n", globals.vals[i].id, globals.vals[i].val);
  }
  printf("-- GLOBALS --\n\n");
}

#ifdef TEST
int main(void) {
  var_enter_func();
  var_dump();
  var_declare_global("a", 2121);
  var_declare("a", 100);
  var_dump();
  var_declare("b", 200);
  var_dump();
  printf("%d\n", var_get("a"));
  var_enter_func();
  var_dump();
  printf("%d\n", var_get("a"));
  var_declare("a", 42);
  var_dump();
  var_declare("x", 432);
  var_dump();
  printf("%d\n", var_get("a"));
  var_enter_block();
  var_dump();
  var_declare("a", 9999);
  var_dump();
  var_set("x", 10000);
  var_dump();
  printf("%d\n", var_get("a"));
  printf("%d\n", var_get("x"));
  var_leave_func();
  var_dump();
  var_leave_func();
  var_dump();
  printf("%d\n", var_get("a"));
}

#endif
