#include "ast.h"
#include <stdio.h>
#include <stdlib.h>

ast *node_create(int type) {
  ast *node = calloc(sizeof(ast), 1);
  node->type = type;
  node->ast_type = AST_LEAF;
  return node;
}

ast *unode_create(int type, ast *operand) {
  ast *node = calloc(sizeof(ast), 1);
  node->type = type;
  node->ast_type = AST_UNOP;
  node->value.unary.operand = operand;

  return node;
}

ast *binode_create(int type, ast *left, ast *right) {
  ast *node = calloc(sizeof(ast), 1);
  node->type = type;
  node->ast_type = AST_BINOP;
  node->value.binary.left = left;
  node->value.binary.right = right;

  return node;
}
