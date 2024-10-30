class Parser {
	private var tokens: [Token]
	private var current = 0

	private var ptr: Slox

	init(tokens: [Token], slox: Slox) {
		self.tokens = tokens
		self.ptr = slox
	}

	func parse() throws -> [Stmt] {
		var stmts: [Stmt] = []
		while !is_eof {
			stmts.append(try statement())
		}

		return stmts
	}

	private var next: Token {
		return tokens[current]
	}

	private var is_eof: Bool {
		return next.token_type == .eof
	}

	private var previous: Token {
		return tokens[current - 1]
	}

	private func match(_ types: TokenType...) -> Bool {
		for type in types {
			if check(type) {
				advance()
				return true
			}
		}

		return false
	}

	private func check(_ type: TokenType) -> Bool {
		return is_eof ? false : next.token_type == type
	}

	@discardableResult
	private func advance() -> Token {
		if !is_eof {
			current += 1
		}
		return previous
	}

	@discardableResult
	private func consume(_ type: TokenType, _ msg: String) throws -> Token {
		if check(type) { return advance() }

		throw error(next, msg)
	}

	private func error(_ token: Token, _ msg: String) -> Error {
		ptr.error(token, msg)
		return ParseError()
	}

	private func synchronize() {
		advance()

		while !is_eof {
			if previous.token_type == .semicolon {
				return
			}

			switch next.token_type {
			case .class, .fn, .var, .for, .if, .while, .print, .return: return
			default: advance()
			}
		}
	}

	struct ParseError: Error {}
}

extension Parser {
	private func expression() throws -> Expr {
		return try equality()
	}

	private func equality() throws -> Expr {
		var expr = try comparison()

		if match(.bangEqual, .equalEqual) {
			let op = previous
			let right = try comparison()
			expr = .binary(Expr.Binary(left: expr, op: op, right: right))
		}

		return expr
	}

	private func comparison() throws -> Expr {
		var expr = try term()

		if match(.greater, .greaterEqual, .less, .lessEqual) {
			let op = previous
			let right = try term()
			expr = .binary(Expr.Binary(left: expr, op: op, right: right))
		}

		return expr
	}

	private func term() throws -> Expr {
		var expr = try factor()

		if match(.minus, .plus) {
			let op = previous
			let right = try factor()
			expr = .binary(Expr.Binary(left: expr, op: op, right: right))
		}

		return expr
	}

	private func factor() throws -> Expr {
		var expr = try unary()

		if match(.slash, .star) {
			let op = previous
			let right = try unary()
			expr = .binary(Expr.Binary(left: expr, op: op, right: right))
		}

		return expr
	}

	private func unary() throws -> Expr {
		if match(.bang, .minus) {
			let op = previous
			let expr = try unary()
			return .unary(Expr.Unary(op: op, right: expr))
		}

		return try primary()
	}

	private func primary() throws -> Expr {
		if match(.true) { return .literal(Expr.Literal(value: .bool(true))) }
		if match(.false) { return .literal(Expr.Literal(value: .bool(false))) }
		if match(.null) { return .literal(Expr.Literal(value: .null)) }

		if match(.number(0), .string("")) {
			return .literal(Expr.Literal(value: previous.get_value()!))
		}

		if match(.leftParen) {
			let expr = try expression()
			try consume(.rightParen, "Expect a ')' token after expression.")
			return .grouping(Expr.Grouping(expression: expr))
		}

		throw error(next, "Expect expression.")
	}
}

extension Parser {
	private func statement() throws -> Stmt {
		if match(.print) {
			return try print_stmt()
		}

		return try expression_stmt()
	}

	private func expression_stmt() throws -> Stmt {
		let expr = try expression()
		try consume(.semicolon, "Expect ';' after a statement.")
		return .expression(Stmt.Expression(expression: expr))
	}

	private func print_stmt() throws -> Stmt {
		let value = try expression()
		try consume(.semicolon, "Expect ';' after a statment.")
		return .print(Stmt.Print(expression: value))
	}
}
