//
//  BitCoding.swift
//  HaffmanCoding
//
//  Created by Yury Lapitsky on 12/14/15.
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
    
    func fillWithZeros(fullSize: Int) -> String {
        let diff = fullSize - self.characters.count
        return (diff == 0) ? self : generateZeroString(diff) + self
    }
}

extension Dictionary {
    
}

public typealias DoubleWord = UInt32

private let bitsInByte = 8
private let doubleWordBitsAmount = sizeof(DoubleWord) * bitsInByte
public let bytesInUInt32 = 4
public struct BytesSequence {
    public let bytes: [DoubleWord]
    public let lastCellSymbolsLeft: Int
}

public class BitsDecoder {
    public static func doubleWordToString(doubleWord: DoubleWord) -> String {
        return String(doubleWord, radix: 2).fillWithZeros(doubleWordBitsAmount)
    }
    
    public static func decodeDoubleWordsToString(doubleWords: [DoubleWord]) -> String {
        return doubleWords.reduce("") { current, next -> String in current + doubleWordToString(next) }
    }
    
    private static func fixLastSymbols(doubleWord: DoubleWord, decodingMap: [String: Character], digitsLeft: Int, decoded: String) -> String? {
        if (digitsLeft == 0) {
            return decoded
        } else {
            let unwantedStringRange = ((doubleWordBitsAmount - digitsLeft)...(doubleWordBitsAmount - 1))
            let digitsString = doubleWordToString(doubleWord)
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
        let combinedString = doubleWords.reduce("") { current, next -> String in current + doubleWordToString(next) }
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
    public static func bitsToDoubleWord(bits: [Bit]) -> DoubleWord {
        let lastBitIndex = (bits.count - 1)
        let startIndex = 0
        let result = (startIndex...lastBitIndex).reduce(DoubleWord(0)) { currentSum, index -> DoubleWord in
            return currentSum + DoubleWord(bits[index].rawValue << (lastBitIndex - index))
        }
        
        return result
    }
    
    static func bitSequencesToByteSequences(sequences: [[Bit]]) -> BytesSequence {
        var currentIntegerStorage = DoubleWord(0)
        var octetsStorage = [DoubleWord]()
        var symbolsLeft = doubleWordBitsAmount
        for sequence in sequences {
            let digitsAmount = sequence.count
            
            if (symbolsLeft == 0) {
                octetsStorage.append(currentIntegerStorage)
                currentIntegerStorage = DoubleWord(0)
                symbolsLeft = doubleWordBitsAmount
            }
            
            if (symbolsLeft < digitsAmount) {
                let diff = digitsAmount - symbolsLeft
                let sequencePartLeft = Array(sequence[0...(symbolsLeft - 1)])
                let sequencePartRight = Array(sequence[(symbolsLeft)...(symbolsLeft + diff) - 1])
                let numberPartLeft = bitsToDoubleWord(sequencePartLeft)
                let numberPartRight = bitsToDoubleWord(sequencePartRight)
                currentIntegerStorage = currentIntegerStorage | numberPartLeft
                octetsStorage.append(currentIntegerStorage)
                let shiftedRightPart = (numberPartRight << (DoubleWord(doubleWordBitsAmount) - DoubleWord(diff)))
                currentIntegerStorage = DoubleWord(0) | shiftedRightPart
                symbolsLeft = doubleWordBitsAmount - diff
            } else {
                let number = bitsToDoubleWord(sequence)
                let shiftSize = DoubleWord(symbolsLeft - digitsAmount)
                let shiftedNumber = number << shiftSize
                
                currentIntegerStorage = currentIntegerStorage | shiftedNumber
                symbolsLeft = Int(shiftSize)
            }
        }
        
        if symbolsLeft < doubleWordBitsAmount {
            octetsStorage.append(currentIntegerStorage)
        }
        
        return BytesSequence(bytes: octetsStorage, lastCellSymbolsLeft: symbolsLeft)
    }
}