//
//  String+RegEx.swift
//  compiler
//
//  Created by KokiHirokawa on 2019/04/07.
//  Copyright © 2019 KokiHirokawa. All rights reserved.
//

import Foundation

extension String {

    func isMatch(pattern: String) -> Bool {
//        do {
//            let regExp = try NSRegularExpression(pattern: pattern)
//            let cnt = regExp.numberOfMatches(in: self, range: NSMakeRange(0, self.count))
//            return cnt != 0
//        } catch {
//        }
        guard let regExp = try? NSRegularExpression(pattern: pattern) else { return false }
        let cnt = regExp.numberOfMatches(in: self, range: NSMakeRange(0, self.count))
        return cnt != 0
    }

    func firstMatch(pattern: String) -> NSTextCheckingResult? {
//        do {
//            let regExp = try NSRegularExpression(pattern: pattern)
//            let match = regExp.firstMatch(in: self, range: NSMakeRange(0, self.count))
//            return match
//        } catch {
//        }
        guard let regExp = try? NSRegularExpression(pattern: pattern) else { return nil }
        let match = regExp.firstMatch(in: self, range: NSMakeRange(0, self.count))
        return match
    }
}
