import lib

#define_expr_ast([
	("Assign", [("name", "Token"), ("value", "Expr")]),
	("Binary", [("left", "Expr"), ("op", "Token"), ("right", "Expr")]),
	("Grouping", [("expression", "Expr")]),
	("Literal", [("value", "Value")]),
	("Unary", [("op", "Token"), ("right", "Expr")]),
	("Variable", [("name", "Token")]),
])

/*
class AstPrinter: Expr.Visitor {
	func print(_ expr: Expr) -> String {
		return try! expr.visit(self)
	}

	private func parenthesize(_ name: String, _ exprs: Expr...) throws -> String {
		var result = "(\(name)"
		for expr in exprs {
			result += " \(try expr.visit(self))"
		}
		result += ")"

		return result
	}

	typealias R = String

	func visit_binary(_ expr: Expr.Binary) throws -> String {
		return try parenthesize(expr.op.token_type.description, expr.left, expr.right)
	}

	func visit_grouping(_ expr: Expr.Grouping) throws -> String {
		return try parenthesize("group", expr.expression)
	}

	func visit_literal(_ expr: Expr.Literal) throws -> String {
		return expr.value.description
	}

	func visit_unary(_ expr: Expr.Unary) throws -> String {
		return try parenthesize(expr.op.token_type.description, expr.right)
	}
}
*/
