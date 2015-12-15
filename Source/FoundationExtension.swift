//
//  FoundationExtension.swift
//  HaffmanCoding
//
//  Created by Yury Lapitsky on 12/15/15.
//  Copyright © 2015 skyylex. All rights reserved.
//

import Foundation

public extension String {
    public func bitsSequence() -> [Bit] {
        return self.characters.map { element -> Bit in
            return (element == "0") ? .Zero : .One
        }
    }
    
    public static func bitString(bits: [Bit]) -> String {
        let characters = bits.map { element -> Character in
            return (element == .One) ? "1" : "0"
        }
        
        return String (characters)
    }
    
    private func generateZeroString(zerosAmount: Int) -> String {
        let range = (0...(zerosAmount - 1))
        return range.reduce("") { current, _ -> String in current + "0" }
    }
    
    public func fillWithZeros(fullSize: Int) -> String {
        let diff = fullSize - self.characters.count
        return (diff == 0) ? self : generateZeroString(diff) + self
    }
}

public extension Dictionary {
    public func join(other: Dictionary) -> Dictionary {
        var copy = self
        copy.update(other)
        return copy
    }
    
    private mutating func update(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}