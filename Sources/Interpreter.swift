class Interpreter: Expr.Visitor, Stmt.Visitor {
	func interpret(_ stmts: [Stmt]) throws {
		for stmt in stmts {
			try execute(stmt)
		}
	}

	@discardableResult
	private func evaluate(_ expr: Expr) throws -> Value {
		return try expr.visit(self)
	}

	private func execute(_ stmt: Stmt) throws {
		try stmt.visit(self)
	}
}

extension Interpreter {
	typealias S = Void

	func visit_print(_ stmt: Stmt.Print) throws {
		let value = try evaluate(stmt.expression)
		print(value)
	}

	func visit_expression(_ stmt: Stmt.Expression) throws {
		try evaluate(stmt.expression)
	}
}

extension Interpreter {
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
