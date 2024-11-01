class Interpreter: Expr.Visitor, Stmt.Visitor {
	private var env = Environment()

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

	private func execute_block(_ stmts: [Stmt], _ env: Environment) throws {
		let previous = self.env
		self.env = env

		// even if try throws some error swap back the envs
		defer {
			self.env = previous
		}

		for stmt in stmts {
			try execute(stmt)
		}
	}
}

extension Interpreter {
	typealias S = Void

	func visit_block(_ stmt: Stmt.Block) throws {
		try execute_block(stmt.statements, Environment(env))
	}

	func visit_print(_ stmt: Stmt.Print) throws {
		let value = try evaluate(stmt.expression)
		print(value)
	}

	func visit_variable(_ stmt: Stmt.Variable) throws {
		var value: Value = .null
		if let init_stmt = stmt.initializer {
			value = try evaluate(init_stmt)
		}

		env.define(stmt.name.token_type.description, value)
	}

	func visit_expression(_ stmt: Stmt.Expression) throws {
		try evaluate(stmt.expression)
	}

	func visit_variable(_ expr: Expr.Variable) throws -> Value {
		try env.get(expr.name)
	}
}

extension Interpreter {
	typealias R = Value

	func visit_assign(_ expr: Expr.Assign) throws -> Value {
		let value = try evaluate(expr.value)
		try env.assign(expr.name, value)
		return value
	}

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

	static func not_found(_ name: Token) -> Self {
		Self(
			name,
			"Undefined variable '\(name.token_type.get_ident() ?? name.token_type.description)'.")
	}
}
