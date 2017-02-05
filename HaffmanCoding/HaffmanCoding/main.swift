//
//  main.swift
//  HaffmanCoding
//
//  Created by Yury Lapitsky on 12/9/15.
//  Copyright © 2015 skyylex. All rights reserved.
//

import Foundation

let s2 = UInt8(255).bits()
let s4 = UInt8(16).bits()
let s3 = UInt8(0).bits()


let text = "MIT License"
let builder = HaffmanTreeBuilder(text: text)
let tree = builder.buildTree()

let universalBuilder = UniversalHaffmanTreeBuilder(filePath: "/Users/yurylapitsky/Temp/sample.jpeg")
let s = universalBuilder.generateDistribution()

if let encodingMap = tree?.generateEncodingMap(), let decodingMap = tree?.generateDecodingMap(), let haffmanTree = tree {
    /// Validation of the encoding/decoding
    print("Validation of the tree: " + String(haffmanTree.validate()))
    
    print("Encoding map: " + String(describing: encodingMap))
    
    var dataStorage = [[Bit]]()
    
    print ("Source text symbols count: " + String(text.characters.count))
    for char in text.characters {
        let key = String(char)
        if let value = encodingMap[char] {
            var digits = value.characters.map { $0 == "0" ? Bit.zero : Bit.one }
            dataStorage.append(digits)
        }
    }
    
    let encodedInfo = BitsCoder.transform(dataStorage)
    
    print("Compressed amount: \(encodedInfo.bytes.count * bytesInUInt32)")
    
    let decodedString = BitsDecoder.decode(encodedInfo.bytes, decodingMap: decodingMap, digitsLeft:encodedInfo.digitsLeft)
    print(decodedString!)
}
