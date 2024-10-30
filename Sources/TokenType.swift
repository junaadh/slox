//
//  TokenType.swift
//  slox
//
//  Created by Junaadh on 29/10/2024.
//

enum TokenType: CustomStringConvertible, Equatable {
    /// Single character tokens
    case leftParen, rightParen, leftBrace, rightBrace,
        comma, dot, minus, plus, semicolon, slash, star

    /// One or Two character tokens
    case bang, bangEqual,
        equal, equalEqual,
        greater, greaterEqual,
        less, lessEqual

    /// Literals
    case comment
    case ident(String)
    case number(Double)
    case string(String)

    /// Keywords
    case and, `class`, `else`, `false`, fn, `for`, `if`, null, or, print, `return`, `super`, this,
        `true`, `var`, `while`

    /// Special
    case eof

    var description: String {
        switch self {
        case .leftParen: return "("
        case .rightParen: return ")"
        case .leftBrace: return "{"
        case .rightBrace: return "}"
        case .comma: return ","
        case .dot: return "."
        case .minus: return "-"
        case .plus: return "+"
        case .semicolon: return ";"
        case .slash: return "/"
        case .star: return "*"

        case .bang: return "!"
        case .bangEqual: return "!="
        case .equal: return "="
        case .equalEqual: return "=="
        case .greater: return ">"
        case .greaterEqual: return ">="
        case .less: return "<"
        case .lessEqual: return "<="

        case .comment: return "<> comment <>"
        case .ident(let i): return i
        case .number(let d): return String(d)
        case .string(let s): return s

        case .and: return "and"
        case .`class`: return "class"
        case .`else`: return "else"
        case .`false`: return "false"
        case .fn: return "fn"
        case .`for`: return "for"
        case .`if`: return "if"
        case .null: return "null"
        case .or: return "or"
        case .print: return "print"
        case .`return`: return "return"
        case .`super`: return "super"
        case .this: return "this"
        case .`true`: return "true"
        case .`var`: return "var"
        case .`while`: return "while"

        case .eof: return "<< eof >>"
        }
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.leftParen, .leftParen), (.rightParen, .rightParen), (.leftBrace, .leftBrace),
            (.rightBrace, .rightBrace), (.comma, .comma), (.dot, .dot), (.minus, .minus),
            (.plus, .plus), (.semicolon, .semicolon), (.slash, .slash), (.star, .star),
            (.bang, .bang), (.bangEqual, .bangEqual), (.equal, .equal), (.equalEqual, .equalEqual),
            (.greater, .greater), (.greaterEqual, .greaterEqual), (.less, .less),
            (.lessEqual, .lessEqual), (.comment, .comment), (.and, .and), (.`class`, .`class`),
            (.`else`, .`else`), (.`false`, .`false`), (.fn, .fn), (.`for`, .`for`), (.`if`, .`if`),
            (.null, .null), (.or, .or), (.print, .print), (.`return`, .`return`),
            (.`super`, .`super`), (.this, .this), (.`true`, .`true`), (.`var`, .`var`),
            (.`while`, .`while`), (.eof, .eof):
            return true
        case (.number(_), .number(_)): return true
        case (.ident(_), .ident(_)): return true
        case (.string(_), .string(_)): return true

        default:
            return false
        }
    }

    func get_inner() -> Value? {
        switch self {
        case .string(let s): return .string(s)
        case .number(let d): return .number(d)
        default:
            return nil
        }
    }

    func get_ident() -> String? {
        if case let .ident(i) = self {
            return i
        } else {
            return nil
        }
    }
}
