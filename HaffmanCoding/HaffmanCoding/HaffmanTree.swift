//
//  HaffmanTree.swift
//  HaffmanCoding
//
//  Created by Yury Lapitsky on 12/9/15.
//  Copyright © 2015 skyylex. All rights reserved.
//

import Foundation

/// [DONE] Phase 1. Get source string and save it
/// [DONE] Phase 2. Parse source string into characters
/// [DONE] Phase 3. Calculate quantity of the each symbols in the text
/// Phase 4. Build HaffmanTree
/// Phase 5. Encode text using created tree
/// Phase 6. Decode encoded text and verity using original string
/// Phase 7. Save text on the file system

public class HaffmanTreeBuilder {
    typealias DistributionMap = [Int : [Character]]
    typealias ReverseDistributionMap = [Character : Int]
    
    let text: String
    
    init(text: String) {
        self.text = text
    }
    
    func generateDistribution() -> DistributionMap {
        let distributionMap = self.text.characters.reduce(ReverseDistributionMap()) { current, next -> ReverseDistributionMap in
            var distributionTable = current
            if let existingQuantity = distributionTable[next] {
                distributionTable[next] = existingQuantity + 1
            } else {
                distributionTable[next] = 1
            }
            
            return distributionTable
        }
        
        let invertedDistributionMap = distributionMap.reduce(DistributionMap()) { currentMap, nextTuple -> DistributionMap in
            let symbol = nextTuple.0
            let quantity = nextTuple.1
            
            var updatedMap = currentMap
            if let existingSymbols = updatedMap[quantity] as Array<Character>? {
                updatedMap[quantity] = existingSymbols + [symbol]
            } else {
                updatedMap[quantity] = [symbol]
            }
            
            return updatedMap
        }
        
        return invertedDistributionMap
    }
    
    func buildTree() -> HaffmanTree {
        typealias TreeBuildResources = (DistributionMap, [HaffmanTree])
        
        let initialBuildResources = (DistributionMap(), [HaffmanTree]())
        let sortedDistribution = generateDistribution().sort { $0.0 > $1.0 }
        
        let mediateResults = sortedDistribution.reduce(initialBuildResources) { current, nextTuple -> TreeBuildResources in
            nextTuple.0
            return (DistributionMap(), [HaffmanTree]())
        }
        
        return HaffmanTree()
    }
    
    private func simplify(tree: HaffmanTree, distribution:[Int:Character]) -> HaffmanTree {
        return HaffmanTree()
    }
}

public class HaffmanTree {
//    let root
    
    func encode(originalText: String) -> String {
        return ""
    }
    
    func decode(encodedText: String) -> String {
        return ""
    }
    
    func verify(originalText: String) -> Bool {
        return decode(encode(originalText)).compare(originalText) == NSComparisonResult.OrderedSame
    }
}