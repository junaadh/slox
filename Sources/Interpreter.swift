class Interpreter: Expr.Visitor {
	func interpret(_ expr: Expr) throws {
		let value = try evaluate(expr)
		print(value)
	}

	private func evaluate(_ expr: Expr) throws -> Value {
		return try expr.visit(self)
	}

	typealias R = Value

	func visit_literal(_ expr: Expr.Literal) throws -> Value {
		return expr.value
	}

	func visit_grouping(_ expr: Expr.Grouping) throws -> Value {
		return try evaluate(expr.expression)
	}

	func visit_unary(_ expr: Expr.Unary) throws -> Value {
		let right = try evaluate(expr.right)

		let s =
			switch expr.op.token_type {
			case .minus: -right
			case .bang: !right
			default: Value.null
			}

		if !s.is_null() {
			return s
		} else {
			throw RuntimeError(expr.op, "Unsupported unary operands.")
		}
	}

	func visit_binary(_ expr: Expr.Binary) throws -> Value {
		let left = try evaluate(expr.left)
		let right = try evaluate(expr.right)

		let s =
			switch expr.op.token_type {
			case .minus: left - right
			case .plus: left + right
			case .star: left * right
			case .slash: left / right

			case .less: Value.bool(left < right)
			case .lessEqual: Value.bool(left <= right)
			case .greater: Value.bool(left > right)
			case .greaterEqual: Value.bool(left >= right)

			case .equalEqual: Value.bool(left == right)
			case .bangEqual: Value.bool(left != right)
			default: Value.null
			}

		if !s.is_null() {
			return s
		} else {
			throw RuntimeError(expr.op, "Unsupported binary operands.")
		}
	}

}

struct RuntimeError: Error {
	let token: Token
	let msg: String

	init(_ token: Token, _ msg: String) {
		self.token = token
		self.msg = msg
	}
}
