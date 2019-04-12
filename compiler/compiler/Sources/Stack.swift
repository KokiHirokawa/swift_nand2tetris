//
//  Stack.swift
//  compiler
//
//  Created by KokiHirokawa on 2019/04/12.
//  Copyright © 2019 KokiHirokawa. All rights reserved.
//

enum Keyword {
    case `class`
    case `function`
}

struct Stack {
    private var items: [Keyword] = []
    
    var lastItem: Keyword? {
        return items.last
    }
    
    var count: Int {
        return items.count
    }
    
    mutating func push(_ item: Keyword) {
        items.append(item)
    }
    
    mutating func pop() {
        items.removeLast()
    }
}
