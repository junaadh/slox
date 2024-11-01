import lib

#define_stmt_ast([
	("Block", [("statements", "[Stmt]")]),
	("Expression", [("expression", "Expr")]),
	("Print", [("expression", "Expr")]),
	("Variable", [("name", "Token"), ("initializer", "Expr?")]),
])
