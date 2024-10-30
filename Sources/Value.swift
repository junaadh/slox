enum Value: CustomStringConvertible, Equatable, Comparable {
	case string(String)
	case number(Double)
	case bool(Bool)
	case null

	func is_null() -> Bool {
		switch self {
		case .null: return true
		default: return false
		}
	}

	static func + (lhs: Self, rhs: Self) -> Self {
		switch (lhs, rhs) {
		case (.string(let l), .string(let r)): return string("\(l)\(r)")
		case (.number(let l), .number(let r)): return number(l + r)
		default: return null
		}
	}

	static func - (lhs: Self, rhs: Self) -> Self {
		switch (lhs, rhs) {
		case (.number(let l), .number(let r)): return number(l - r)
		default: return null
		}
	}

	static func * (lhs: Self, rhs: Self) -> Self {
		switch (lhs, rhs) {
		case (.number(let l), .number(let r)): return number(l * r)
		default: return null
		}
	}

	static func / (lhs: Self, rhs: Self) -> Self {
		switch (lhs, rhs) {
		case (.number(let l), .number(let r)): return number(l / r)
		default: return null
		}
	}

	static func == (lhs: Self, rhs: Self) -> Bool {
		switch (lhs, rhs) {
		case (.number(let l), .number(let r)): l == r
		case (.string(let l), .string(let r)): l == r
		case (.bool(let l), .bool(let r)): l == r
		case (.null, .null): true
		default:
			false
		}
	}

	static func < (lhs: Self, rhs: Self) -> Bool {
		switch (lhs, rhs) {
		case (.number(let l), .number(let r)): return l < r
		case (.string(let l), .string(let r)): return l < r
		default:
			return false
		}
	}

	static prefix func - (value: Self) -> Self {
		switch value {
		case .number(let s): return number(-s)
		default:
			return null
		}
	}

	static prefix func ! (value: Self) -> Self {
		switch value {
		case .bool(let b): return bool(!b)
		default:
			return null
		}
	}

	var description: String {
		switch self {
		case .string(let str): return str
		case .number(let num): return String(num)
		case .bool(let bool): return String(bool)
		case .null: return "null"
		}
	}
}
