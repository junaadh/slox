//
//  TokenType.swift
//  slox
//
//  Created by Junaadh on 29/10/2024.
//

enum TokenType {
    // Single character tokens
    case leftParen, rightParen, leftBrace, rightBrace,
        comma, dot, minus, plus, semicolon, slash, star
         
    // One or Two character tokens
    case bang, bangEqual,
        equal, equalEqual,
        greater, greaterEqual,
        less, lessEqual
    
    // Literals
    case comment, ident(String), number(Double), string(String)
    
    // Keywords
    case and, `class`, `else`, `false`, fn, `for`, `if`, `nil`, or, print, `return`, `super`, this, `true`, `var`, `while`
        
    // Special
    case eof
    
}
