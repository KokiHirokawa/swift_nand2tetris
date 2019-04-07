//
//  NSTextCheckingResult+subscript.swift
//  compiler
//
//  Created by KokiHirokawa on 2019/04/07.
//  Copyright © 2019 KokiHirokawa. All rights reserved.
//

import Foundation

extension NSTextCheckingResult {
    
    subscript(index: Int) -> NSRange? {
        guard index < numberOfRanges else { return nil }
        
        let result = range(at: index)
        guard result.lowerBound != NSNotFound else { return nil }
        
        return result
    }
}
