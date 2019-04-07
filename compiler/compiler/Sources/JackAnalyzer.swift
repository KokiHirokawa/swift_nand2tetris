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
        
        // codeを丸々取ってくるのはOK
        guard
            let data = fileManager.contents(atPath: path),
            var code = String(data: data, encoding: .ascii) else { return }
        
        // exclude comment
        code = try! code.replace(pattern: RegExPattern.commentOut, withTemplate: "\n")
        
        // lineで処理するのもOK
        for line in code.components(separatedBy: .newlines) {

            var statement = line
            statement = statement.trimmingCharacters(in: .whitespaces)
            if statement.isEmpty { continue }

            var index = 0
            while index != statement.length {

                var char = statement[index]
                
                if try! char.isMatch(pattern: RegExPattern.Token.symbol) {

                    if char == "<" {
                        outputCode += "<symbol> &lt; </symbol>\n"
                    } else if char == ">" {
                        outputCode += "<symbol> &gt; </symbol>\n"
                    } else if char == "&" {
                        outputCode += "<symbol> &amp; </symbol>\n"
                    } else {
                        outputCode += "<symbol> \(char) </symbol>\n"
                    }
                    index += 1

                } else if try! char.isMatch(pattern: #"\d"#) {

                    var intConst = ""
                    while try! !char.isMatch(pattern: #"\D"#) {
                        intConst += char
                        index += 1
                        char = statement[index]
                    }
                    outputCode += "<integerConstant> \(intConst) </integerConstant>\n"

                } else if try! char.isMatch(pattern: "[a-zA-Z_]") {

                    var token = ""
                    while try! !char.isMatch(pattern: #"[^\w]"#) {
                        token += char
                        index += 1
                        char = statement[index]
                    }

                    if try! token.isMatch(pattern: RegExPattern.Token.keyword) {
                        outputCode += "<keyword> \(token) </keyword>\n"
                    } else {
                        outputCode += "<identifier> \(token) </identifier>\n"
                    }

                } else if char == "\"" {

                    var strConst = ""
                    index += 1
                    char = statement[index]
                    while char != "\"" {
                        strConst += char
                        index += 1
                        char = statement[index]
                    }
                    outputCode += "<stringConstant> \(strConst) </stringConstant>\n"
                    index += 1

                } else {
                    index += 1
                }
            }
        }
        
        outputCode += "</tokens>"
    }
    
    func output() {
        guard
            let match = try! path.firstMatch(pattern: RegExPattern.Path.jackFilePath),
            let range = match[1] else {
                return
            }
        
        let filename = path[range]
        let data = outputCode.data(using: .ascii)
        fileManager.createFile(atPath: "\(filename)T.xml", contents: data)
    }
}
