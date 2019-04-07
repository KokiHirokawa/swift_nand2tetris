//
//  RegExPattern.swift
//  compiler
//
//  Created by KokiHirokawa on 2019/04/07.
//  Copyright © 2019 KokiHirokawa. All rights reserved.
//

struct RegExPattern {
    
    static let commentOut = #"(/{2}.*|/\*{1,2}.*\*/)"#
    
    struct Path {
        static let jackFilePath = #"(.+)\.jack$"#
    }
    
    struct Token {
        static let keyword = "^(class|constructor|function|method|field|static|var|int|char|boolean|void|true|false|null|this|let|do|if|else|while|return)$"
        static let symbol = #"[{}()\[\].,;+-/&|<>=~*]"#

        static let integerConstant = #"\d"#
        static let stringConstant = #""#
        static let identifier = #""#
    }
}
