//
//  StringExtension.swift
//  CastRemote
//
//  Created by Coty Embry on 1/1/16.
//  Copyright © 2016 cotyembry. All rights reserved.
//
//this code was found at
//http://stackoverflow.com/questions/24092884/get-nth-character-of-a-string-in-swift-programming-language
//which is under the Creative Common License
//http://creativecommons.org/licenses/by/4.0/


import Foundation

//usage:
/*
"abcde"[0] === "a"
"abcde"[0...2] === "abc"
"abcde"[2..<4] === "cd"
*/

extension String {
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: startIndex.advancedBy(r.startIndex), end: startIndex.advancedBy(r.endIndex)))
    }
}