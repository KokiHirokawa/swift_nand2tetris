//
//  JackAnalyzer.swift
//  compiler
//
//  Created by KokiHirokawa on 2019/04/07.
//  Copyright © 2019 KokiHirokawa. All rights reserved.
//

import Foundation

class JackAnalyzer {
    
    private let fileManager = FileManager.default
    private let path: String
    private var outputCode: String
    
    init(path: String) {
        self.path = path
        outputCode = "<tokens>\n"
    }
    
    func run() {
        
        guard
            let data = fileManager.contents(atPath: path),
            let code = String(data: data, encoding: .ascii) else { return }
        
        for line in code.components(separatedBy: .newlines) {
            
            var statement = line
            
            guard let commentOutRegExp = try? NSRegularExpression(pattern: RegExPattern.commentOut) else { return }
            statement = commentOutRegExp.stringByReplacingMatches(in: statement, range: NSMakeRange(0, statement.count), withTemplate: "")
            statement = statement.trimmingCharacters(in: .whitespaces)
            if statement.isEmpty { continue }
            
            var index = statement.startIndex
            
            while index != statement.endIndex {
                
                var char = statement[index].description
                
                if char.isMatch(pattern: RegExPattern.Token.symbol) {
                    
                    if char == "<" {
                        outputCode += "<symbol> &lt; </symbol>\n"
                    } else if char == ">" {
                        outputCode += "<symbol> &gt; </symbol>\n"
                    } else if char == "&" {
                        outputCode += "<symbol> &amp; </symbol>\n"
                    } else {
                        outputCode += "<symbol> \(char) </symbol>\n"
                    }
                    index = statement.index(after: index)
                    
                } else if char.isMatch(pattern: #"\d"#) {
                    
                    var intConst = ""
                    while !char.isMatch(pattern: #"\D"#) {
                        intConst += char
                        index = statement.index(after: index)
                        char = statement[index].description
                    }
                    outputCode += "<integerConstant> \(intConst) </integerConstant>\n"
                    
                } else if char.isMatch(pattern: "[a-zA-Z_]") {
                    
                    var token = ""
                    while !char.isMatch(pattern: #"[^\w]"#) {
                        token += char
                        index = statement.index(after: index)
                        char = statement[index].description
                    }
                    
                    if token.isMatch(pattern: RegExPattern.Token.keyword) {
                        outputCode += "<keyword> \(token) </keyword>\n"
                    } else {
                        outputCode += "<identifier> \(token) </identifier>\n"
                    }
                    
                } else if char == "\"" {
                    
                    var strConst = ""
                    index = statement.index(after: index)
                    char = statement[index].description
                    while char != "\"" {
                        strConst += char
                        index = statement.index(after: index)
                        char = statement[index].description
                    }
                    outputCode += "<stringConstant> \(strConst) </stringConstant>\n"
                    index = statement.index(after: index)
                    
                } else {
                    index = statement.index(after: index)
                }
            }
        }
        
        outputCode += "</tokens>"
    }
    
    func output() {
        guard
            let match = path.firstMatch(pattern: RegExPattern.Path.jackFilePath),
            let range = match[1] else {
                return
        }
        
        let data = outputCode.data(using: .ascii)
        let filename = path[range]
        fileManager.createFile(atPath: "\(filename)T.xml", contents: data)
    }
}
