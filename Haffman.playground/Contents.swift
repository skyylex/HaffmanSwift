//
//  main.swift
//  HaffmanCoding
//
//  Created by Yury Lapitsky on 12/9/15.
//  Copyright © 2015 skyylex. All rights reserved.
//

import Foundation


let text = "MIT License \n\ns"
let builder = HaffmanTreeBuilder(text: text)
let tree = builder.buildTree()

if let encodingMap = tree?.generateEncodingMap(), decodingMap = tree?.generateDecodingMap() {
    let encodingInfo = encodingMap
    var dataStorage = [[Bit]]()
    for char in text.characters {
        let key = String(char)
        if let value = encodingMap[char] {
            var digits = value.characters.map { $0 == "0" ? Bit.Zero : Bit.One }
            dataStorage.append(digits)
        }
    }
    
    let bits = Array(dataStorage.flatten())
    let bitsString = String.bitString(bits)
    let encodedInfo = BitsCoder.transform(dataStorage)
    
    let digits = encodedInfo.bytes
    let decodedString = BitsDecoder.decode(encodedInfo.bytes, decodingMap: decodingMap, digitsLeft:encodedInfo.digitsLeft)
    
    let compressedCount = encodedInfo.bytes.count * bytesInUInt32
    let rawCount = text.characters.count
}
