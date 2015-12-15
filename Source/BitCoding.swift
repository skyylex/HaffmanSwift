//
//  BitCoding.swift
//  HaffmanCoding
//
//  Created by Yury Lapitsky on 12/14/15.
//  Copyright © 2015 skyylex. All rights reserved.
//

import Foundation

public let bytesInUInt32 = 4
public typealias DoubleWord = UInt32

public let bitsInByte = 8
public let doubleWordBitsAmount = sizeof(DoubleWord) * bitsInByte

public struct BytesSequence {
    public let bytes: [DoubleWord]
    public let digitsLeft: Int
}

public class BitsDecoder {
    public static func transform(doubleWord: DoubleWord) -> String {
        return String(doubleWord, radix: 2).fillWithZeros(doubleWordBitsAmount)
    }
    
    public static func transform(doubleWords: [DoubleWord]) -> String {
        return doubleWords.reduce("") { current, next -> String in current + transform(next) }
    }
    
    private static func fixLastSymbols(doubleWord: DoubleWord, decodingMap: [String: Character], digitsLeft: Int, decoded: String) -> String? {
        if (digitsLeft == 0) {
            return decoded
        } else {
            let unwantedStringRange = ((doubleWordBitsAmount - digitsLeft)...(doubleWordBitsAmount - 1))
            let digitsString = transform(doubleWord)
            let unwantedCharaters = Array(digitsString.characters)[unwantedStringRange]
            if let minimum = findShortestKeyLength(decodingMap) {
                let unwantedString = decode(String(unwantedCharaters), decodingMap: decodingMap, minDigitsAmount: minimum)
                let endIndex = decoded.characters.count - 1
                let startIndex = endIndex - unwantedString.characters.count
                let fixed = Array(decoded.characters)[(0...startIndex)]
                return String(fixed)
            } else {
                return nil
            }
        }
    }
    
    public static func decode(doubleWords: [DoubleWord], decodingMap:[String: Character], digitsLeft: Int) -> String? {
        let combinedString = transform(doubleWords)
        if let mininumAmount = findShortestKeyLength(decodingMap) {
            let decoded = decode(combinedString, decodingMap: decodingMap, minDigitsAmount:mininumAmount)
            let lastDoubleWord = doubleWords[doubleWords.count - 1]
            return fixLastSymbols(lastDoubleWord, decodingMap: decodingMap, digitsLeft: digitsLeft, decoded: decoded)
        } else {
            return nil
        }
        
    }
    
    private static func findShortestKeyLength(decodingMap:[String: Character]) -> Int? {
        if let first = decodingMap.keys.first {
            let randomMinimum = first.characters.count
            return decodingMap.keys.reduce(randomMinimum) { currentMinimum, next -> Int in
                let next = next.characters.count
                let min = (currentMinimum <= next) ? currentMinimum : next
                return min
            }
        } else {
            return nil
        }
    }
    
    private static func decode(encodedString: String, decodingMap: [String: Character], minDigitsAmount: Int) -> String {
        let (_, decoded) = encodedString.characters.reduce(("", "")) { current, nextSymbol -> (String, String) in
            let buffer = current.0
            let decoded = current.1
            if buffer.characters.count < minDigitsAmount {
                return (buffer + String(nextSymbol), decoded)
            } else {
                if let decodedSymbol = decodingMap[buffer] {
                    return ("" + String(nextSymbol), decoded + String(decodedSymbol))
                }
            }
            
            return (buffer + String(nextSymbol), decoded)
        }
        
        return decoded
    }
}

public class BitsCoder {
    public static func transform(bits: [Bit]) -> DoubleWord {
        let endIndex = (bits.count - 1)
        let startIndex = 0
        let result = (startIndex...endIndex).reduce(DoubleWord(0)) { currentSum, nextIndex -> DoubleWord in
            return currentSum + DoubleWord(bits[nextIndex].rawValue << (endIndex - nextIndex))
        }
        
        return result
    }
    
    public static func transform(sequences: [[Bit]]) -> BytesSequence {
        var buffer = DoubleWord(0)
        var storage = [DoubleWord]()
        var digitsLeft = doubleWordBitsAmount
        for digitsSequence in sequences {
            let digitsAmount = digitsSequence.count
            
            if (digitsLeft == 0) {
                storage.append(buffer)
                buffer = DoubleWord(0)
                digitsLeft = doubleWordBitsAmount
            }
            
            if (digitsLeft < digitsAmount) {
                let diff = digitsAmount - digitsLeft
                let digitsPartLeft = Array(digitsSequence[0...(digitsLeft - 1)])
                let digitsPartRight = Array(digitsSequence[(digitsLeft)...(digitsLeft + diff) - 1])
                let doubleWordPartLeft = transform(digitsPartLeft)
                let doubleWordPartRight = transform(digitsPartRight)
                buffer = buffer | doubleWordPartLeft
                storage.append(buffer)
                let shiftedRightPart = (doubleWordPartRight << (DoubleWord(doubleWordBitsAmount) - DoubleWord(diff)))
                buffer = DoubleWord(0) | shiftedRightPart
                digitsLeft = doubleWordBitsAmount - diff
            } else {
                let doubleWord = transform(digitsSequence)
                let shiftLength = DoubleWord(digitsLeft - digitsAmount)
                let shiftedNumber = doubleWord << shiftLength
                
                buffer = buffer | shiftedNumber
                digitsLeft = Int(shiftLength)
            }
        }
        
        if digitsLeft < doubleWordBitsAmount {
            storage.append(buffer)
        }
        
        return BytesSequence(bytes: storage, digitsLeft: digitsLeft)
    }
}