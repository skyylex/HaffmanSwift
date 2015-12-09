//
//  main.swift
//  HaffmanCoding
//
//  Created by Yury Lapitsky on 12/9/15.
//  Copyright © 2015 skyylex. All rights reserved.
//

import Foundation

let textString = "Hello, World!"
print(textString)

let builder = HaffmanTreeBuilder(text: textString)
print(builder.generateDistribution())