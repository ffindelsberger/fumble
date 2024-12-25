#include "ast.h"
#include "mem.c"
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

const char *getAstTypeName(int astType) {
  switch (astType) {
  case AST_LEAF:
    return "AST_LEAF";
  case AST_UNOP:
    return "AST_UNOP";
  case AST_BINOP:
    return "AST_BINOP";
  case ITEM:
    return "ITEM";
  case CALL:
    return "CALL";
  case CONDITION_IF:
    return "CONDITION_IF";
  case LOOP:
    return "LOOP";
  default:
    return "Unknown AST Type";
  }
}

ast *create_leaf(enum KindLeaf kind) {
  ast *n = calloc(sizeof(ast), 1);
  n->node.leaf.kind = kind;
  n->ast_type = AST_LEAF;

  printf("creatd leaf with kind type %d \n", n->node.leaf.kind);
  return n;
}

ast *unode_create(int type, ast *operand) {
  ast *n = calloc(sizeof(ast), 1);
  // n->type = type;
  n->ast_type = AST_UNOP;
  n->node.unary.operand = operand;
  n->node.unary.op = type;

  return n;
}

ast *binode_create(int type, ast *left, ast *right) {
  ast *n = calloc(sizeof(ast), 1);
  n->type = type;
  n->ast_type = AST_BINOP;
  n->node.binary.left = left;
  n->node.binary.right = right;
  n->node.binary.kind = type;
  return n;
}

ast *create_if(ast *condition, ast *branch_if, ast *branch_else) {
  ast *n = calloc(sizeof(ast), 1);

  n->ast_type = CONDITION_IF;
  n->node.condition_if.condition = condition;
  n->node.condition_if.branch_if = branch_if;
  n->node.condition_if.branch_else = branch_else;

  return n;
}

ast *create_loop(ast *body) {
  ast *n = calloc(sizeof(ast), 1);

  n->ast_type = LOOP;
  n->node.loop.body = body;

  return n;
}

data data_init(data_t t, data_value v) {
  data d;
  d.t = t;
  d.v = v;
  return d;
}

extern bool break_f;

data eval(ast *ast) {
  data empty = {};

  printf("interpreting ast type: %s : \n", getAstTypeName(ast->ast_type));

  switch (ast->ast_type) {

  case AST_UNOP:
    switch (ast->node.unary.op) {
    case UNOP_MINUS: {
      data d;
      d.t = INTEGER;
      d.v.number = -eval(ast->node.unary.operand).v.number;
      return d;
    }
    }

  case AST_BINOP:
    switch (ast->node.binary.kind) {
    // create a check for a skip flag in here;
    case STMTS: {
      // printf("stmts: break_f = %d \n", break_f);
      data left = eval(ast->node.binary.left);
      data right = {};
      if (!break_f) {
        right = eval(ast->node.binary.right);
      }
      return left, right;
    }
    case MUL: {
      data d;
      d.t = INTEGER;
      d.v.number = eval(ast->node.binary.left).v.number *
                   eval(ast->node.binary.right).v.number;
      return d;
    }
    case PLUS: {
      data d;
      d.t = INTEGER;
      d.v.number = eval(ast->node.binary.left).v.number +
                   eval(ast->node.binary.right).v.number;
      return d;
    }
    case MINUS: {
      data d;
      d.t = INTEGER;
      d.v.number = eval(ast->node.binary.left).v.number -
                   eval(ast->node.binary.right).v.number;
      return d;
    }
    case LESS: {

      data d;
      d.t = INTEGER;
      d.v.number = eval(ast->node.binary.left).v.number <
                   eval(ast->node.binary.right).v.number;
      return d;
    }
    case GREATER: {
      data d;
      d.t = INTEGER;
      d.v.number = eval(ast->node.binary.left).v.number >
                   eval(ast->node.binary.right).v.number;
      return d;
    }
    case MOD: {
      data d;
      d.t = INTEGER;
      d.v.number = eval(ast->node.binary.left).v.number %
                   eval(ast->node.binary.right).v.number;
      return d;
    }
    case DIV: {
      data d;
      d.t = INTEGER;
      d.v.number = eval(ast->node.binary.left).v.number /
                   eval(ast->node.binary.right).v.number;
      return d;
    }
    case EQUAL: {
      data d;
      d.t = INTEGER;
      d.v.number = eval(ast->node.binary.left).v.number ==
                   eval(ast->node.binary.right).v.number;
      return d;
    }
    case NEQUAL: {
      data d;
      d.t = INTEGER;
      d.v.number = eval(ast->node.binary.left).v.number !=
                   eval(ast->node.binary.right).v.number;
      return d;
    }
    case ELESS: {
      data d;
      d.t = INTEGER;
      d.v.number = eval(ast->node.binary.left).v.number >=
                   eval(ast->node.binary.right).v.number;
      return d;
    }
    case EGREATER: {
      data d;
      d.t = INTEGER;
      d.v.number = eval(ast->node.binary.left).v.number <=
                   eval(ast->node.binary.right).v.number;
      return d;
    }
    case ASSIGN: {
      // printf("eq\n");
      int val = eval(ast->node.binary.right);
      char *id = ast->node.binary.left->identifier;
      return var_set(id, val);
    }
    case DECL: {
      char *id = ast->node.binary.left->identifier;
      int data = eval(ast->node.binary.right);
      // printf("let -> declaring variable : %s with node %d \n", id, data);
      return var_declare(id, data);
    }

    default: {
      data d = {};
      return d;
    }
    }

  case AST_LEAF:
    // printf("kind is %d \n", ast->node.leaf.kind);
    switch (ast->node.leaf.kind) {
    case NUMLIT: {
      data d;
      d.t = INTEGER;
      d.v.number = ast->data.number;
      return d;
    }
    case STRLIT: {
      // printf("kind is %d \n", ast->node.leaf.kind);
      // printf("string_literal\n");
      // printf("node of string literal is : %s \n", ast->data.string);
      data d;
      d.t = STRING;
      d.v.string = ast->data.string;
      return d;
    }
    case IDENT: {
      data ret = var_get(ast->identifier);
      printf("id -> returning node: %d for id : %s \n", ret, ast->identifier);
      return ret;
    }
    case BREAK: {
      // printf("break\n");
      break_f = true;
      data d = {};
      return d;
    }
    case NEXT_INT: {
      // printf("next_int\n");
      int next_int_value;
      //*c will read the newline to discard it;
      scanf("%d%*c", &next_int_value);
      data d = {};
      d.v.number = next_int_value;
      d.t = INTEGER;
      return d;
    }
    default: {
      data d = {};
      return d;
    }
    }

  case CONDITION_IF: {
    // printf("conditional_if\n");
    if (eval(ast->node.condition_if.condition).v.number) {
      return eval(ast->node.condition_if.branch_if);
    } else {
      if (ast->node.condition_if.branch_else != NULL) {
        return eval(ast->node.condition_if.branch_else);
      }
    }
    data d = {};
    return d;
  }
  case LOOP: {
    data result;
    while (!break_f) {
      result = eval(ast->node.loop.body);
    }
    break_f = false;
    return result;
  }
  }

  return empty;
}
