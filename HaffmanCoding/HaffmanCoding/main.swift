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
let text = try NSString(contentsOfURL: url, encoding: NSUTF8StringEncoding)

if let aliveText = text as String? {
    let builder = HaffmanTreeBuilder(text: aliveText)
    print(builder.generateDistribution().sort { first, second -> Bool in
        return first.0 > second.0
    })
    print("\n\n")
    
    let tree = builder.buildTree()
    
    let s = tree?.generateEncodingMap().sort({ first, second -> Bool in
        return first.1.characters.count > second.1.characters.count
    })
    
    print ("\n\n" + String(s))
}