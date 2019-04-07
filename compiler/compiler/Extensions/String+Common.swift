//
//  String+Common.swift
//  compiler
//
//  Created by KokiHirokawa on 2019/04/07.
//  Copyright © 2019 KokiHirokawa. All rights reserved.
//

import Foundation

extension String {
    
    var length: Int {
        get {
            return count
        }
    }
    
    subscript(i: Int) -> String {
        get {
            let index = self.index(startIndex, offsetBy: i)
            
            if !indices.contains(index) {
                print("String index is out of bounds")
                print("string: \(self), index: \(i)")
            }
            
            return self[index].description
        }
    }
    
    subscript(r: Range<Int>) -> String {
        get {
            let startIndex = index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = index(self.startIndex, offsetBy: r.upperBound)
            print(startIndex, endIndex)
            
            if !indices.contains(startIndex) || !indices.contains(endIndex) {
                print("String index is out of bounds")
                print("string: \(self), range: \(r)")
            }
            
            return self[startIndex..<endIndex].description
        }
    }
    
    subscript(r: NSRange) -> String {
        if r.lowerBound == NSNotFound {
            print("String index is out of bounds")
            print("string: \(self), range: \(r)")
        }
        
        let nsString = self as NSString
        let subString = nsString.substring(with: r)
        return String(subString)
    }
    
    subscript(r: ClosedRange<Int>) -> String {
        get {
            let lowerBound = r.lowerBound
            let upperBound = r.upperBound
            
            if 0...length ~= lowerBound || 0...length ~= upperBound {
                print("String index is out of bounds")
                print("string: \(self), range: \(r)")
            }
            
            let startIndex = index(self.startIndex, offsetBy: lowerBound)
            let endIndex = index(self.startIndex, offsetBy: upperBound)
            print(startIndex, endIndex)
            
            return self[startIndex...endIndex].description
        }
    }
    
    func replace(pattern: String, withTemplate: String) throws -> String {
        let regEx = try NSRegularExpression(pattern: pattern)
        return regEx.stringByReplacingMatches(in: self, range: NSMakeRange(0, self.length), withTemplate: withTemplate)
    }
    
    func isMatch(pattern: String) throws -> Bool {
        let regExp = try NSRegularExpression(pattern: pattern)
        let matchCount = regExp.numberOfMatches(in: self, range: NSMakeRange(0, count))
        return matchCount > 0
    }

    func firstMatch(pattern: String) throws -> NSTextCheckingResult? {
        let regExp = try NSRegularExpression(pattern: pattern)
        return regExp.firstMatch(in: self, range: NSMakeRange(0, count))
    }
}
