//
//  Token.swift
//  slox
//
//  Created by Junaadh on 29/10/2024.
//

struct Token: CustomStringConvertible {
    let token_type: TokenType
    let line: Int
    
    init(token_type: TokenType, line: Int) {
        self.token_type = token_type
        self.line = line
    }
    
    var description: String {
        return "Token(\(token_type), \(line))"
    }
}
