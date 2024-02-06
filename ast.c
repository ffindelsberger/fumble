#include "ast.h"
#include <stdio.h>
#include <stdlib.h>

ast *node_create(int type) {
  ast *n = calloc(sizeof(ast), 1);
  n->type = type;
  n->ast_type = AST_LEAF;
  return n;
}

ast *unode_create(int type, ast *operand) {
  ast *n = calloc(sizeof(ast), 1);
  n->type = type;
  n->ast_type = AST_UNOP;
  n->node.unary.operand = operand;

  return n;
}

ast *binode_create(int type, ast *left, ast *right) {
  ast *n = calloc(sizeof(ast), 1);
  n->type = type;
  n->ast_type = AST_BINOP;
  n->node.binary.left = left;
  n->node.binary.right = right;

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
