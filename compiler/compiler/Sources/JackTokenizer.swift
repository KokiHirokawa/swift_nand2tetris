//
//  JackTokenizer.swift
//  compiler
//
//  Created by KokiHirokawa on 2019/04/07.
//  Copyright © 2019 KokiHirokawa. All rights reserved.
//

import Foundation

class JackTokenizer {
    
    private let fp: UnsafeMutablePointer<FILE>
    private var row = 1
    private var column = 1
    private var currentAsciiCode: Int32
    private var currentChar: String {
        return String(UnicodeScalar(UInt8(currentAsciiCode)))
    }
    private var tokens = [Token]()
    private let lineFeed = 10
    
    init(path: String) {
        guard let fp = fopen(path, "r") else {
            fatalError("Failed to open a file (errno: \(errno))")
        }
        
        self.fp = fp
        self.currentAsciiCode = fgetc(fp)
    }
    
    func tokenize() {
        
        if currentAsciiCode == EOF {
            return
        }
        
        excludeCommentOut()
        
        if try! currentChar.isMatch(pattern: RegExPattern.Token.symbol) {
            tokenizeSymbol()
        } else if try! currentChar.isMatch(pattern: RegExPattern.Token.integerConstant) {
            tokenizeIntConst()
        } else if try! currentChar.isMatch(pattern: "[a-zA-Z_]") {
            tokenizeKeywordOrIdentifier()
        } else if currentChar == "\"" {
            tokenizeStrConst()
        } else {
            next()
        }
        
        tokenize()
    }
    
    func getTokens() {
        print("<tokens>")
        tokens.forEach { token in
            print("<\(token.type)> \(token.value) </\(token.type)> (row: \(token.row) col: \(token.col))")
        }
        print("</tokens>")
    }
    
    func excludeCommentOut() {
        if currentChar == "/" {
            next()
            switch currentChar {
            case "/":
                while currentAsciiCode != lineFeed {
                    next()
                }
            case "*":
                while true {
                    next()
                    if currentChar == "*" {
                        next()
                        if currentChar == "/" {
                            next()
                            break
                        }
                    }
                }
            default:
                // show line and row
                fatalError(#"illegal token "/" (row: \#(row), column: \#(column))"#)
            }
        }
    }
    
    private func next() {
        currentAsciiCode = fgetc(fp)
        if currentAsciiCode == lineFeed {
            row += 1
            column = 0
        } else {
            column += 1
        }
    }

    func tokenizeSymbol() {
        var value: String
        
        switch currentChar {
        case "<":
            value = "&lt;"
        case ">":
            value = "&gt;"
        case "&":
            value = "&amp;"
        default:
            value = currentChar
        }
        
        appendToken(type: .symbol, value: value, row: row, col: column)
        next()
    }
    
    func tokenizeIntConst() {
        var value = ""
        let leadColumn = column
        
        while true {
            if try! currentChar.isMatch(pattern: #"\D"#) {
                appendToken(type: .integerConstant, value: value, row: row, col: leadColumn)
                break
            }
            value += currentChar
            next()
        }
    }
    
    func tokenizeStrConst() {
        var value = ""
        let leadColumn = column
        
        while true {
            next()
            if currentChar == "\"" {
                appendToken(type: .stringConstant, value: value, row: row, col: leadColumn)
                next()
                break
            }
            value += currentChar
        }
    }
    
    func tokenizeKeywordOrIdentifier() {
        var value = ""
        let leadColumn = column
        
        while true {
            if try! currentChar.isMatch(pattern: #"[^\w]"#) {
                var type: TokenType
                
                if try! value.isMatch(pattern: RegExPattern.Token.keyword) {
                    type = .keyword
                } else {
                    type = .identifier
                }
                
                appendToken(type: type, value: value, row: row, col: leadColumn)
                break
            }
            
            value += currentChar
            next()
        }
    }
    
    func appendToken(type: TokenType, value: String, row: Int, col: Int) {
        let token = Token(type: type, value: value, row: row, col: col)
        tokens.append(token)
    }
    
//    func tokenType() -> TokenType {
//        
//    }
//
//    func keyword() {
//
//    }
//
//    func symbol() -> String {
//
//    }
//
//    func identifier() -> String {
//
//    }
//
//    func intVal() -> String {
//
//    }
//
//    func stringVal() -> String {
//
//    }
}

enum TokenType {
    case keyword
    case symbol
    case identifier
    case integerConstant
    case stringConstant
}

enum KeywordType {
    case `class`
    case method
    case function
    case constructor
    case int
    case boolean
    case char
    case void
    case `var`
    case `static`
    case field
    case `let`
    case `do`
    case `if`
    case `else`
    case `while`
    case `return`
    case `true`
    case `false`
    case null
    case this
}

struct Token {
    let type: TokenType
    let value: String
    let row: Int
    let col: Int
}
