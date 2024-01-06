#include <stdlib.h>
// static const int CHILDREN_CAPACITY = 5;
//
// typedef struct ast_node {
//   int type;
//
//   union {
//     int number;
//     char *string;
//   } val;
//
//   struct ast_node *children[CHILDREN_CAPACITY];
// } ast_node;

///
enum data_type { INTEGER, STRING };
union data_value {
  int number;
  char *string;
};

// struct node_data {
//   enum data_type type;
//   union data_value value;
// };

typedef struct ast {
  // The "type" of the node as represented by Bisons generated identifiers for
  // terminals and NonTerminals
  int type;

  enum data_type data_type;
  // "data" is the actual data value stored in the ast node. to inquire which
  // member of the union is populated inquire the data_type enum
  union data_value data;

  enum { AST_LEAF, AST_UNOP, AST_BINOP } ast_type;
  union {

    struct {
      enum { UNOP_MINUS } op;
      struct ast *operand;
    } unary;

    struct {
      struct ast *left;
      struct ast *right;
    } binary;

  } value;
} ast;

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
