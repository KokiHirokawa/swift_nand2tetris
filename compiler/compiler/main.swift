//
//  main.swift
//  compiler
//
//  Created by KokiHirokawa on 2019/04/07.
//  Copyright © 2019 KokiHirokawa. All rights reserved.
//

import Foundation

func run() {

    if CommandLine.argc != 2 {
        print("usage: ./compiler [dir|file path]")
        return
    }
    
    let path = CommandLine.arguments[1]
    let analyzer = JackAnalyzer(path: path)
    analyzer.run()
//    analyzer.output()
}

run()
