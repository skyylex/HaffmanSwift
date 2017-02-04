//
//  FoundationExtension.swift
//  HaffmanCoding
//
//  Created by Yury Lapitsky on 12/15/15.
//  Copyright © 2015 skyylex. All rights reserved.
//

import Foundation

public enum Bit {
    case zero
    case one
    
    func rawValue() -> UInt8 {
        return (self == .zero) ? 0 : 1;
    }
}

public extension String {
    public func bitsSequence() -> [Bit] {
        return self.characters.map { element -> Bit in
            return (element == "0") ? .zero : .one
        }
    }
    
    public static func bitString(_ bits: [Bit]) -> String {
        let characters = bits.map { element -> Character in
            return (element == .one) ? "1" : "0"
        }
        
        return String (characters)
    }
    
    fileprivate func generateZeroString(_ zerosAmount: Int) -> String {
        let range = (0...(zerosAmount - 1))
        return range.reduce("") { current, _ -> String in current + "0" }
    }
    
    public func fillWithZeros(_ fullSize: Int) -> String {
        let diff = fullSize - self.characters.count
        return (diff == 0) ? self : generateZeroString(diff) + self
    }
}

public extension Dictionary {
    public func join(_ other: Dictionary) -> Dictionary {
        var copy = self
        copy.update(other)
        return copy
    }
    
    fileprivate mutating func update(_ other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}
