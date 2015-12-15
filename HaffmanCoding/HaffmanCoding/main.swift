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
print("size: " + String(NSData(contentsOfURL: url)?.length))
print("\n\n ===== \n\n");
//let text = try NSString(contentsOfURL: url, encoding: NSUTF8StringEncoding)
let text = "The MIT License (MIT) Copyright (c) 2015 Yury Lapitsky"

print(text)


if let aliveText = text as String? {
    let builder = HaffmanTreeBuilder(text: aliveText)
    print(builder.generateDistribution().sort { first, second -> Bool in
        return first.0 > second.0
    })
    print("\n\n")
    
    let tree = builder.buildTree()
    
    if let encodingMap = tree?.generateEncodingMap(), decodingMap = tree?.generateDecodingMap() {
        /// Validation of the encoding/decoding
        print("Validation result: " + String(tree?.validate()))
        
        print(encodingMap)
        
        var dataStorage = [[Bit]]()
        
        print ("aliveText chars count: " + String(aliveText.characters.count))
        for char in aliveText.characters {
            let key = String(char)
            if let value = encodingMap[char] {
                var digits = value.characters.map { $0 == "0" ? Bit.Zero : Bit.One }
                dataStorage.append(digits)
            }
        }
        
        let bitsCollection = dataStorage.flatten()
        let bitsString = String.bitString(Array(bitsCollection))
        print("Raw: " + bitsString)
        
        let encodedData = BitsCoder.bitSequencesToByteSequences(dataStorage)
        let binaryStringFromBytes = BitsDecoder.decodeDoubleWordsToString(encodedData.bytes)
        print("Decoded: " + binaryStringFromBytes)
        
        print("Compare: " + String(binaryStringFromBytes.compare(bitsString)))
        
        print("Compressed amount: \(encodedData.bytes.count * 4)")
        
        let decodedString = BitsDecoder.decodeDoubleWordSequence(encodedData.bytes, decodingMap: decodingMap, lastElementBitsLeft:encodedData.lastCellSymbolsLeft)
        print(decodedString)
    }
}