class Environment {
	private var enclosing: Environment?
	private var values: [String: Value] = [:]

	init(_ enclosing: Environment? = nil) {
		self.enclosing = enclosing
	}

	func define(_ name: String, _ value: Value) {
		values.updateValue(value, forKey: name)
	}

	func get(_ token: Token) throws -> Value {
		if let value = values[token.token_type.description] {
			return value
		} else if let outer = enclosing {
			return try outer.get(token)
		}

		throw RuntimeError.not_found(token)
	}

	func assign(_ token: Token, _ value: Value) throws {
		if values[token.token_type.description] != nil {
			values.updateValue(value, forKey: token.token_type.description)
		} else if let outer = enclosing {
			try outer.assign(token, value)
		}

		throw RuntimeError.not_found(token)
	}
}
