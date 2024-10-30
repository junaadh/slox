# Macro library for Slox

## exported macros
- used to define expr
"""swift
  #define_expr_ast([
    ("Unary", [("op", "Token"), ("right", "Expr")]) 
  ])
"""

- used to define stmt
"""swift
  #define_stmt_ast([
    ("Expression", [("expression", "Expr")]) 
  ])
"""

## macro exported items
- define_/**/_ast exports Expr and Stmt globally
- each enum has included visitor protocol
