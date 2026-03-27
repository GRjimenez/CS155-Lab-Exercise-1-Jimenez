%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *msg);
int yylex(void);

typedef struct Node {
    char *label;
    struct Node *left;
    struct Node *middle;
    struct Node *right;
} Node;

Node* makeFloatNode(double val) {
    Node *newNode = (Node*)malloc(sizeof(Node));
    newNode->label = (char*)malloc(32);
    sprintf(newNode->label, "%g", val); 
    newNode->left = newNode->middle = newNode->right = NULL;
    return newNode;
}

Node* makeNode(char *label, Node *left, Node *middle, Node *right) {
    Node *newNode = (Node*)malloc(sizeof(Node));
    newNode->label = label;
    newNode->left = left;
    newNode->middle = middle;
    newNode->right = right;
    return newNode;
}

Node* makeNumNode(int val) {
    Node *newNode = (Node*)malloc(sizeof(Node));
    newNode->label = (char*)malloc(32);
    sprintf(newNode->label, "%d", val);
    newNode->left = newNode->middle = newNode->right = NULL;
    return newNode;
}

int depth = 0; 

void indent(int d) {
    for(int i = 0; i < d * 2; i++) {
        printf(" ");
    }
}

void printTree(Node *n) {
    if (n == NULL) return;
    indent(depth);
    printf("%s\n", n->label);
    depth++; 
    printTree(n->left);
    printTree(n->middle);
    printTree(n->right);
    depth--; 
}
%}

%union {
    int ival;
    double fval;
    struct Node* node; 
}

%token <ival> NUM
%token <fval> FNUM
%token PLUS MINUS TIMES DIVIDE LPAREN RPAREN EXP

%left PLUS MINUS
%left TIMES DIVIDE
%right EXP    
%right UMINUS

%type <node> program expr term factor

%%

program:
    expr { 
        printf("Parse Tree:\n");
        printTree($1); 
    }
    ;

expr:
    expr PLUS term  { $$ = makeNode("expr", $1, makeNode("+", NULL, NULL, NULL), $3); }
  | expr MINUS term { $$ = makeNode("expr", $1, makeNode("-", NULL, NULL, NULL), $3); }
  | term            { $$ = makeNode("expr", $1, NULL, NULL); }
  ;

term:
    term TIMES factor { $$ = makeNode("term", $1, makeNode("*", NULL, NULL, NULL), $3); }
  | term DIVIDE factor { $$ = makeNode("term", $1, makeNode("/", NULL, NULL, NULL), $3); }
  | factor            { $$ = makeNode("term", $1, NULL, NULL); }
  ;

factor:
    NUM                 { $$ = makeNode("factor", makeNumNode($1), NULL, NULL); }
  | FNUM                { $$ = makeNode("factor", makeFloatNode($1), NULL, NULL); }
  | factor EXP factor   { $$ = makeNode("factor", $1, makeNode("^", NULL, NULL, NULL), $3); }
  | LPAREN expr RPAREN  { $$ = makeNode("factor", makeNode("(", NULL, NULL, NULL), $2, makeNode(")", NULL, NULL, NULL)); }
  | MINUS factor %prec UMINUS { $$ = makeNode("factor", makeNode("-", NULL, NULL, NULL), $2, NULL); }
  ;

%%

void yyerror(const char *msg) {
    fprintf(stderr, "Parse error: %s\n", msg);
}

int main(void) {
    return yyparse();
}