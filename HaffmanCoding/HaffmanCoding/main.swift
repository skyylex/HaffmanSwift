//
//  main.swift
//  HaffmanCoding
//
//  Created by Yury Lapitsky on 12/9/15.
//  Copyright © 2015 skyylex. All rights reserved.
//

import Foundation

let link = "https://wordpress.org/plugins/about/readme.txt"
let url = NSURL(string: link)!
let text = try NSString(contentsOfURL: url, encoding: NSUTF8StringEncoding)

if let aliveText = text as String? {
    print("Origin text:" + aliveText)
    let builder = HaffmanTreeBuilder(text: aliveText)
    let tree = builder.buildTree()
    
    if let encodingMap = tree?.generateEncodingMap(), decodingMap = tree?.generateDecodingMap() {
        /// Validation of the encoding/decoding
        print("Validation of the tree: " + String(tree?.validate()))
        
        print("Encoding map: " + String(encodingMap))
        
        var dataStorage = [[Bit]]()
        
        print ("Source text symbols count: " + String(aliveText.characters.count))
        for char in aliveText.characters {
            let key = String(char)
            if let value = encodingMap[char] {
                var digits = value.characters.map { $0 == "0" ? Bit.Zero : Bit.One }
                dataStorage.append(digits)
            }
        }
                
        let encodedInfo = BitsCoder.bitSequencesToByteSequences(dataStorage)
        let binaryStringFromBytes = BitsDecoder.decodeDoubleWordsToString(encodedInfo.bytes)
        
        print("Compressed amount: \(encodedInfo.bytes.count * bytesInUInt32)")
        
        let decodedString = BitsDecoder.decode(encodedInfo.bytes, decodingMap: decodingMap, digitsLeft:encodedInfo.lastCellSymbolsLeft)
        print(decodedString)
    }
}