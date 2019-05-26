//
//  JackAnalyzer.swift
//  compiler
//
//  Created by KokiHirokawa on 2019/04/07.
//  Copyright © 2019 KokiHirokawa. All rights reserved.
//

import Foundation

struct Node {
    let kind: NodeKind
    let first: Int
    let last: Int
    var nodes: [Node]?
    // 終端文字フラグ？
}

enum NodeKind {
    case keyword
    case symbol
    case integerConstant
    case stringConstant
    case identifier
    case `class`
    case classVarDec
    case type
    case subroutineDec
    case parameterList
    case subroutineBody
    case varDec
    case className
    case subroutineName
    case varName
}

class JackAnalyzer {
    
    private let path: String
    private let tokenizer: JackTokenizer
    
    private let fileManager = FileManager.default
    private var nodeTree: Node?
    private var tokens = [Token]()
    private var tokenIndex = 0
    private var currentToken: Token {
        return tokens[tokenIndex]
    }
    
    init(path: String) {
        self.path = path
        tokenizer = JackTokenizer(path: path)
    }
    
    func run() {
        
        tokenizer.tokenize()
//        tokenizer.printTokens()
        tokens = tokenizer.getTokens()
        
        if currentToken.type == .keyword && currentToken.value == "class" {
            compileClass()
        } else {
            fatalError("no class.")
        }
    }
    
    func nextToken() {
        tokenIndex += 1
    }
    
    func compile() -> Node {
        let value = currentToken.value
        
        if try! value.isMatch(pattern: "^(static|field)$") {
            return compileClassVarDec()
        } else if try! value.isMatch(pattern: "^(constructor|function|method)$") {
            return compileSubroutineDec()
        }
        
        fatalError("コンパイルに失敗しました。")
    }
    
    func compileClass() {
        print("compileClass.")
        
        let first = tokenIndex
        var index = tokenIndex
        
        while tokens[index].value != "{" {
            index += 1
        }
        
        index += 1
        var numberOfBraces = 1
        while true {
            
            let value = tokens[index].value
            
            if value == "{" {
                numberOfBraces += 1
            } else if value == "}" {
                numberOfBraces -= 1
            }
            
            if numberOfBraces == 0 {
                break
            }
            
            index += 1
        }
        
        var classNode = Node(kind: .class, first: first, last: index, nodes: [])
        print("<class>")
        
        classNode.nodes?.append(Node(kind: .keyword, first: 0, last: 0, nodes: nil))
        print("  <keyword> \(currentToken.value) </keyword>")
        nextToken()
        
        classNode.nodes?.append(Node(kind: .identifier, first: 1, last: 1, nodes: nil))
        print("  <identifier> \(currentToken.value) </identifier>")
        nextToken()
        
        classNode.nodes?.append(Node(kind: .symbol, first: 2, last: 2, nodes: nil))
        print("  <identifier> \(currentToken.value) </identifier>")
        nextToken()
        
        while tokenIndex != index {
            let node = compile()
            classNode.nodes?.append(node)
        }
        
        classNode.nodes?.append(Node(kind: .symbol, first: tokenIndex, last: tokenIndex, nodes: nil))
        print("  <symbol> \(currentToken.value) </symbol>")
        print("</class>")
        
        nodeTree = classNode
    }
    
//    func compileClassVarDec() -> Node {
//
//        let first = tokenIndex
//        var index = tokenIndex
//
//        while tokens[index].value != ";" {
//            index += 1
//        }
//
//        let last = index
//
//        var node = Node(kind: .classVarDec, first: first, last: last, nodes: [])
//        node.nodes?.append(Node(kind: .keyword, first: tokenIndex, last: tokenIndex, nodes: nil))
//        tokenIndex += 1
//        // 終端文字まで分解した方が本当は良さそう…
//        node.nodes?.append(Node(kind: .type, first: tokenIndex, last: tokenIndex, nodes: nil))
//        tokenIndex += 1
//        node.nodes?.append(Node(kind: .identifier, first: tokenIndex, last: tokenIndex, nodes: nil))
//        tokenIndex += 1
//
//        // (',' varName)* ';'
//        while tokenIndex != last {
//            // compileAddVarDec
//        }
//
//        node.nodes?.append(Node(kind: .symbol, first: tokenIndex, last: tokenIndex, nodes: nil))
//        tokenIndex += 1
//
//        return node
//    }
    
    func compileClassVarDec() -> Node {
        
        let first = tokenIndex
        
        while currentToken.value != ";" {
            nextToken()
        }
        
        let node = Node(kind: .classVarDec, first: first, last: tokenIndex, nodes: nil)
        nextToken()
        print("  <classVarDec></classVarDec>")
        return node
    }
    
//    func compileSubroutineDec() -> Node {
//
//        var numberOfBraces = 0
//        var index = tokenIndex
//
//        while index != tokens.count - 1 {
//            let value = tokens[index].value
//            if value == "{" {
//                numberOfBraces += 1
//            }
//            index += 1
//        }
//
//        index = tokenIndex
//
//        while numberOfBraces != 0 {
//
//            let token = tokens[index]
//            if token.value == "}" {
//                numberOfBraces -= 1
//            }
//            index += 1
//        }
//
//        var node = Node(kind: .subroutineDec, first: tokenIndex, last: index-1, nodes: [])
//
//        node.nodes?.append(Node(kind: .identifier, first: tokenIndex, last: tokenIndex, nodes: nil))
//        tokenIndex += 1
//
//        node.nodes?.append(compileType())
//
//        node.nodes?.append(Node(kind: .identifier, first: tokenIndex, last: tokenIndex, nodes: nil))
//        tokenIndex += 1
//
//        node.nodes?.append(Node(kind: .symbol, first: tokenIndex, last: tokenIndex, nodes: nil))
//        tokenIndex += 1
//
//        return node
//    }
    
    func compileSubroutineDec() -> Node {
        
        let first = tokenIndex
        
        while currentToken.value != "{" {
            nextToken()
        }
        
        var numberOfBraces = 1
        nextToken()
        
        while true {
            
            if currentToken.value == "{" {
                numberOfBraces += 1
            } else if currentToken.value == "}" {
                numberOfBraces -= 1
            }
            
            if numberOfBraces == 0 {
                break
            }
            
            nextToken()
        }
        
        let node = Node(kind: .subroutineDec, first: first, last: tokenIndex, nodes: nil)
        nextToken()
        print("  <subroutineDec></subroutineDec>")
        return node
    }
    
    func compileType() -> Node {
        var node = Node(kind: .type, first: tokenIndex, last: tokenIndex, nodes: [])
        
        
        if try! currentToken.value.isMatch(pattern: "^(int|char|boolean)$") {
            node.nodes?.append(Node(kind: .keyword, first: tokenIndex, last: tokenIndex, nodes: nil))
        } else {
            node.nodes?.append(Node(kind: .identifier, first: tokenIndex, last: tokenIndex, nodes: nil))
        }
        tokenIndex += 1
        
        return node
    }
    
    func compileParameterList() -> Node {
        // テキトー
        let node = Node(kind: .parameterList, first: tokenIndex, last: tokenIndex, nodes: nil)
        return node
    }
    
    func compileVarDec() -> Node {
        // テキトー
        let node = Node(kind: .parameterList, first: tokenIndex, last: tokenIndex, nodes: nil)
        return node
    }
    
    func output() {
//        guard
//            let match = try! path.firstMatch(pattern: RegExPattern.Path.jackFilePath),
//            let range = match[1] else {
//                return
//            }
//
//        let filename = path[range]
//        let data = outputCode.data(using: .ascii)
//        fileManager.createFile(atPath: "\(filename)T.xml", contents: data)
    }
}
