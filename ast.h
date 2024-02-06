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
typedef enum { INTEGER, STRING } data_t;
typedef union {
  int number;
  char *string;
} data_value;

typedef struct data {
  data_t t;
  data_value v;
} data;

// struct node_data {
//   enum data_type type;
//   union data_value value;
// };

typedef struct ast {
  // The "type" of the node as represented by Bisons generated identifiers for
  // terminals and NonTerminals
  int type;

  data_t data_type;
  // "data" is the actual data value stored in the ast node. to inquire which
  // member of the union is populated inquire the data_type enum
  data_value data;

  char *identifier;

  enum {
    AST_LEAF,
    AST_UNOP,
    AST_BINOP,
    ITEM,
    CALL,
    CONDITION_IF,
    LOOP
  } ast_type;
  union {

    struct {
      data_t data_t;
      data_value data_v;
    } leaf;

    struct {
      enum { UNOP_MINUS } op;
      struct ast *operand;
    } unary;

    struct {
      struct ast *left;
      struct ast *right;
    } binary;

    struct {
      struct ast *body;
    } loop;

    struct {
      char *identifier;
      struct ast *fparam;
      struct ast *fn;
    } item;

    struct {
      char *identifier;
      struct ast *aparam;
      struct ast *body;
    } call_exp;

    struct {
      struct ast *condition;
      struct ast *branch_if;
      struct ast *branch_else;
    } condition_if;

  } node;

} ast;

data eval(ast *tree);
ast *node_create(int type);
ast *node_create_with_type(int type, data_t data_type);
ast *binode_create(int type, ast *left, ast *right);
ast *unode_create(int type, ast *operand);
ast *create_if(ast *condition, ast *branch_if, ast *branch_else);
ast *create_loop(ast *body);
