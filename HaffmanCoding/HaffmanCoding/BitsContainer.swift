//
//  BitsContainer.swift
//  HaffmanCoding
//
//  Created by Yury Lapitsky on 05/02/2017.
//  Copyright © 2017 skyylex. All rights reserved.
//

import Foundation

public enum Bit {
    case zero
    case one
    
    func rawValue() -> UInt8 {
        return (self == .zero) ? 0 : 1;
    }
}

public extension UInt8 {
    func bits() -> [Bit] {
        var bits = [Bit]()
        
        for order in (0...7) {
            let bit: Bit = ((self & UInt8(1 << order)) == 0) ? Bit.zero : Bit.one
            bits.append(bit)
        }
        return bits
    }
}

public class BitsContainer {
    private(set) var bytes: [UInt8] = [UInt8(0)]
    private(set) var availableBitPosition: UInt8 = UInt8(0)
    
    init() { }
    
    init(bits: [Bit]) {
        add(bits: bits)
    }
    
    static func empty() -> BitsContainer { return BitsContainer() }
    
    func appendToLeft(from: BitsContainer) {
        var summaryBits = [Bit]()
        for byte in from.bytes {
            summaryBits = byte.bits() + summaryBits
        }
        
        add(bits: summaryBits)
    }
    
    func add(bits: [Bit]) {
        for bit in bits { add(bit: bit) }
    }
    
    func add(bit: Bit) {
        guard let _ = bytes.last else { preconditionFailure() }
        
        if bit == .one {
            let additional = bit.rawValue() << availableBitPosition
            self.bytes[bytes.count - 1] += additional
        }
        
        // Increase storage by one byte & start new counter
        if availableBitPosition == 7 {
            bytes = bytes + [UInt8(0)]
            availableBitPosition = 0
        }
        else {
            // Shift inside byte
            availableBitPosition += 1
        }
    }
    
    func abstractRepresentation() -> [Bit] {
        // TODO:
        return [Bit]()
    }
    
    func description() -> String {
        var description: String = ""
        
        let lastIndex = (bytes.count - 1)
        for index in (0...lastIndex) {
            let reversedIndex = lastIndex - index
            let byte = bytes[reversedIndex]
            var binary = String(byte, radix: 2)
            
            if binary.characters.count < 8 {
                var zeroFillingString: String = ""
                if reversedIndex != lastIndex {
                    let diff = 7 - binary.characters.count
                    if diff > 0 {
                        zeroFillingString = (0...diff).reduce("") { current, value in return "0" + current }
                    }
                } else {
                    let diff = Int(self.availableBitPosition) - Int(binary.characters.count)
                    if diff > 0 {
                        zeroFillingString = (0...diff).reduce("") { current, value in return "0" + current }
                    }
                }
                
                binary = zeroFillingString + binary
            }
            
            description += binary
            description += " "
        }
        
        return description
    }
}

extension BitsContainer : Hashable {
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: BitsContainer, rhs: BitsContainer) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    public var hashValue: Int {
        return description().hash
    }
}
