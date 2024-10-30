class Scanner {
    private var source: String
    private var start: String.UnicodeScalarIndex
    private var current: String.UnicodeScalarIndex
    private var line: Int = 1
    private var ptr: Slox

    private var tokens: [Token] = []

    init(source: String, _ ptr: Slox) {
        self.source = source
        self.source.append("\0")
        self.start = source.unicodeScalars.startIndex
        self.current = source.unicodeScalars.startIndex
        self.ptr = ptr
    }

    func scan_tokens() -> [Token] {
        while !is_eof() {
            start = current
            scan_token()
        }

        return tokens
    }

    private func scan_token() {
        let char = advance()
        switch char {
        case "(": add_token(make_token(.leftParen))
        case ")": add_token(make_token(.rightParen))
        case "{": add_token(make_token(.leftBrace))
        case "}": add_token(make_token(.rightBrace))
        case ",": add_token(make_token(.comma))
        case ".": add_token(make_token(.dot))
        case "-": add_token(make_token(.minus))
        case "+": add_token(make_token(.plus))
        case ";": add_token(make_token(.semicolon))
        case "*": add_token(make_token(.star))

        case "/":
            if match("/") {
                self.advance_while { char in
                    return char != "\n"
                }
                add_token(make_token(.comment))
            } else {
                add_token(make_token(.slash))
            }

        case "!": add_token(make_token(match("=") ? .bangEqual : .bang))
        case "=": add_token(make_token(match("=") ? .equalEqual : .equal))
        case ">": add_token(make_token(match("=") ? .greaterEqual : .greater))
        case "<": add_token(make_token(match("=") ? .lessEqual : .less))

        case "\"": string()
        // TODO: throw error token
        case _ where char.is_digit(): number()
        case _ where char.is_alpha(): identifier()

        case _ where char.is_whitespace(): return
        case "\0": add_token(make_token(.eof))

        default: ptr.error(line, "Unexpected character.")
        }
    }

    private func add_token(_ token: Token) {
        tokens.append(token)
    }

    private func match(_ expected: UnicodeScalar) -> Bool {
        if is_eof() { return false }
        if source.unicodeScalars[current] != expected {
            return false
        }

        self.advance()
        return true
    }

    private func is_eof() -> Bool {
        return current >= source.unicodeScalars.endIndex
    }

    @discardableResult private func advance() -> UnicodeScalar {
        let result = source.unicodeScalars[current]
        current = source.unicodeScalars.index(after: current)

        if result == "\n" {
            line += 1
        }
        return result
    }
}

extension Scanner {
    private func make_token(_ kind: TokenType) -> Token {
        return Token(token_type: kind, line: line)
    }

    private func sub_string() -> String {
        return String(source.unicodeScalars[start..<current])
    }

    private func advance_while(_ predicate: (UnicodeScalar) -> Bool) {
        while !is_eof() && predicate(source.unicodeScalars[current]) {
            self.advance()
        }
    }

    private func number() {
        advance_while { char in
            return char.is_digit()
        }

        if match(".") {
            advance_while { char in
                return char.is_digit()
            }
        }

        guard let number = Double(sub_string()) else {
            ptr.error(line, "Invalid number")
            return
        }

        add_token(make_token(.number(number)))
    }

    private func string() {
        advance_while { char in
            return char != "\""
        }

        if is_eof() {
            ptr.error(line, "Unterminated string")
        } else {
            advance()
            add_token(
                make_token(.string(String(sub_string().dropFirst().dropLast())))
            )
        }
    }

    private func identifier() {
        advance_while { char in
            return char.is_alpha() || char.is_digit()
        }
        let ident = sub_string()

        switch ident {
        case "and": add_token(make_token(.and))
        case "class": add_token(make_token(.class))
        case "else": add_token(make_token(.else))
        case "false": add_token(make_token(.false))
        case "fn": add_token(make_token(.fn))
        case "for": add_token(make_token(.for))
        case "if": add_token(make_token(.if))
        case "null": add_token(make_token(.null))
        case "or": add_token(make_token(.or))
        case "print": add_token(make_token(.print))
        case "return": add_token(make_token(.return))
        case "super": add_token(make_token(.super))
        case "this": add_token(make_token(.this))
        case "true": add_token(make_token(.true))
        case "var": add_token(make_token(.var))
        case "while": add_token(make_token(.while))

        default: add_token(make_token(.ident(ident)))
        }
    }
}

extension UnicodeScalar {
    fileprivate func is_whitespace() -> Bool {
        return self == "\t" || self == " " || self == "\r" || self == "\n"
    }

    fileprivate func is_alpha() -> Bool {
        return (self >= "a" && self <= "z") || (self >= "A" && self <= "Z") || self == "_"
    }

    fileprivate func is_digit() -> Bool {
        return self >= "0" && self <= "9"
    }
}
