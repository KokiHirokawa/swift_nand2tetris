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
    case statements
    case letStatement
    case ifStatement
    case whileStatement
    case doStatement
    case returnStatement
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
        print("  <symbol> \(currentToken.value) </symbol>")
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
    
    func compileClassVarDec() -> Node {

        let first = tokenIndex
        var index = tokenIndex

        while tokens[index].value != ";" {
            index += 1
        }

        let last = index

        var node = Node(kind: .classVarDec, first: first, last: last, nodes: [])
        print("  <classVarDec>")
        
        node.nodes?.append(Node(kind: .keyword, first: tokenIndex, last: tokenIndex, nodes: nil))
        print("    <keyword> \(currentToken.value) </keyword>")
        nextToken()
        
        node.nodes?.append(compileType())
        
        node.nodes?.append(Node(kind: .identifier, first: tokenIndex, last: tokenIndex, nodes: nil))
        print("    <identifier> \(currentToken.value) </identifier>")
        nextToken()

        // (',' varName)* ';'
        while tokenIndex != last {
            // compileAddVarDec
        }

        node.nodes?.append(Node(kind: .symbol, first: tokenIndex, last: tokenIndex, nodes: nil))
        print("    <symbol> \(currentToken.value) </symbol>")
        nextToken()
        
        print("  </classVarDec>")

        return node
    }
    
    func compileSubroutineDec() -> Node {

        let first = tokenIndex
        var index = tokenIndex
        
        while tokens[index].value != "{" {
            index += 1
        }
        
        var numberOfBraces = 1
        index += 1
        
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

        let last = index

        var node = Node(kind: .subroutineDec, first: first, last: last, nodes: [])
        print("  <subroutineDec>")

        node.nodes?.append(Node(kind: .keyword, first: tokenIndex, last: tokenIndex, nodes: nil))
        print("    <keyword> \(currentToken.value) </keyword>")
        nextToken()

        node.nodes?.append(compileType())

        node.nodes?.append(Node(kind: .identifier, first: tokenIndex, last: tokenIndex, nodes: nil))
        print("    <identifier> \(currentToken.value) </identifier>")
        nextToken()

        node.nodes?.append(Node(kind: .symbol, first: tokenIndex, last: tokenIndex, nodes: nil))
        print("    <symbol> \(currentToken.value) </symbol>")
        nextToken()
        
        node.nodes?.append(compileParameterList())
        
        node.nodes?.append(Node(kind: .symbol, first: tokenIndex, last: tokenIndex, nodes: nil))
        print("    <symbol> \(currentToken.value) </symbol>")
        nextToken()
        
        node.nodes?.append(compileSubroutineBody(last: last))

        print("  </subroutineDec>")
        return node
    }
    
    func compileType() -> Node {
        var node = Node(kind: .type, first: tokenIndex, last: tokenIndex, nodes: [])
        
        if try! currentToken.value.isMatch(pattern: "^(int|char|boolean)$") {
            node.nodes?.append(Node(kind: .keyword, first: tokenIndex, last: tokenIndex, nodes: nil))
            print("    <keyword> \(currentToken.value) </keyword>")
        } else {
            node.nodes?.append(Node(kind: .identifier, first: tokenIndex, last: tokenIndex, nodes: nil))
            print("    <identifier> \(currentToken.value) </identifier>")
        }
        nextToken()
        
        return node
    }
    
    func compileParameterList() -> Node {
        
        let first = tokenIndex
        
        while currentToken.value != ")" {
            nextToken()
        }
        
        let last = tokenIndex
        
        let node = Node(kind: .parameterList, first: first, last: last, nodes: [])
        print("    <parameterList>")
        print("    </parameterList>")
        return node
    }
    
    func compileSubroutineBody(last: Int) -> Node {
        var node = Node(kind: .subroutineBody, first: tokenIndex, last: last, nodes: [])
        print("    <subroutineBody>")
        
        node.nodes?.append(Node(kind: .symbol, first: tokenIndex, last: tokenIndex, nodes: nil))
        print("    <symbol> \(currentToken.value) </symbol>")
        nextToken()
        
        while tokenIndex != last {
            
            let value = currentToken.value
            
            if value == "var" {
                let varDecNode = compileVarDec()
                node.nodes?.append(varDecNode)
            } else {
                let statementsNode = compileStatements()
                node.nodes?.append(statementsNode)
                tokenIndex = last
            }
        }
        
        node.nodes?.append(Node(kind: .symbol, first: tokenIndex, last: tokenIndex, nodes: nil))
        print("    <symbol> \(currentToken.value) </symbol>")
        nextToken()
        
        print("    </subroutineBody>")
        return node
    }
    
    func compileVarDec() -> Node {
        
        let first = tokenIndex
        var index = tokenIndex
        
        while tokens[index].value != ";" {
            index += 1
        }
        
        let last = index
        
        var node = Node(kind: .varDec, first: first, last: last, nodes: [])
        print("      <varDec>")
        
        node.nodes?.append(Node(kind: .keyword, first: tokenIndex, last: tokenIndex, nodes: nil))
        print("        <keyword> \(currentToken.value) </keyword>")
        nextToken()
        
        node.nodes?.append(compileType())
        
        node.nodes?.append(Node(kind: .identifier, first: tokenIndex, last: tokenIndex, nodes: nil))
        print("        <identifier> \(currentToken.value) </identifier>")
        nextToken()
        
        while tokenIndex != last {
            node.nodes?.append(Node(kind: .symbol, first: tokenIndex, last: tokenIndex, nodes: nil))
            print("        <symbol> \(currentToken.value) </symbol>")
            nextToken()
            
            node.nodes?.append(Node(kind: .identifier, first: tokenIndex, last: tokenIndex, nodes: nil))
            print("        <identifier> \(currentToken.value) </identifier>")
            nextToken()
        }
        
        node.nodes?.append(Node(kind: .symbol, first: tokenIndex, last: tokenIndex, nodes: nil))
        print("        <symbol> \(currentToken.value) </symbol>")
        nextToken()
        
        print("      </varDec>")
        return node
    }
    
    func compileStatements() -> Node {
        let node = Node(kind: .statements, first: 0, last: 0, nodes: nil)
        print("      <statements>")
        print("      </statements>")
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
