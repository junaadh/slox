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
			guard let stmt = try declaration() else {
				continue
			}
			stmts.append(stmt)
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

		print(next, type)
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
		return try assignment()
	}

	private func assignment() throws -> Expr {
		let expr = try equality()

		if match(.equal) {
			let equal = previous
			let value = try assignment()

			if case let Expr.variable(ex) = expr {
				let name = ex.name
				return .assign(Expr.Assign(name: name, value: value))
			}

			throw error(equal, "Invalid assignment target.")
		}

		return expr
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

		if match(.ident("")) {
			return .variable(Expr.Variable(name: previous))
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
	private func declaration() throws -> Stmt? {
		do {
			if match(.var) {
				return try var_declaration()
			}
			if match(.comment) {
				return nil
			}

			return try statement()
		} catch {
			synchronize()
			return nil
		}
	}

	private func block() throws -> [Stmt] {
		var statements: [Stmt] = []

		while !check(.rightBrace) && !is_eof {
			if let stmt = try declaration() {
				statements.append(stmt)
			}
		}

		try consume(.rightBrace, "Expected '}' after block.")
		return statements
	}

	private func statement() throws -> Stmt {
		if match(.print) {
			return try print_stmt()
		}
		if match(.leftBrace) {
			return Stmt.block(Stmt.Block(statements: try block()))
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

	private func var_declaration() throws -> Stmt {
		let name = try consume(.ident(""), "Expect variable name")

		var expr: Expr? = nil
		if match(.equal) {
			expr = try expression()
		}

		try consume(.semicolon, "Expect ';' after a statement.")
		return .variable(Stmt.Variable(name: name, initializer: expr))
	}
}
