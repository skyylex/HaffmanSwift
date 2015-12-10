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
/// [DONE] Phase 4. Build HaffmanTree
/// Phase 5. Create encoding map
/// Phase 6. Encode text using created tree
/// Phase 7. Decode encoded text and verity using original string
/// Phase 8. Save text on the file system

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
    
    func buildTree() -> HaffmanTree? {
        let sortedDistribution = generateDistribution().sort { $0.0 < $1.0 }
        
        let collectedTrees = sortedDistribution.reduce([HaffmanTree]()) { collectedTrees, nextTuple -> [HaffmanTree] in
            let quantity = nextTuple.0
            let symbols = nextTuple.1
            
            let trees = symbols.map { symbol -> HaffmanTree in
                let node = Node(value: String(symbol), quantity: quantity)
                return HaffmanTree(root: node)
            }
            
            return collectedTrees + trees
        }
        
        let sortedTrees = collectedTrees.sort { first, second -> Bool in first.root.quantity < second.root.quantity }
        let finalTrees = simplify(sortedTrees)
        precondition(finalTrees.count == 1)
        
        let finalTree = finalTrees.first
        digitize(finalTree?.root)
        
        return finalTree
    }
    
    func digitize(node: Node?) {
        if let aliveNode = node {
            aliveNode.leftChild?.digit = 0
            aliveNode.rightChild?.digit = 1
            
            digitize(aliveNode.leftChild)
            digitize(aliveNode.rightChild)
        }
    }

    private func simplify(trees: [HaffmanTree]) -> [HaffmanTree] {
        print(trees.map { $0.root.symbol } )
        if trees.count == 1 {
            return trees
        } else {
            let first = trees[0], second = trees[1]
            let combinedTree = first.join(second)
            let partedTrees = (trees.count > 2) ? Array(trees[2...(trees.count - 1)]) : [HaffmanTree]()
            
            let beforeInsertingTreesAmount = partedTrees.count
            let updatedTreeGroup = partedTrees.reduce([HaffmanTree]()) { collectedTrees, nextTree -> [HaffmanTree] in
                var mutableCollectedTrees = collectedTrees
                if (combinedTree.root.quantity < nextTree.root.quantity) {
                    mutableCollectedTrees.append(combinedTree)
                }
                mutableCollectedTrees.append(nextTree)
                
                return mutableCollectedTrees
            }
            let afterInsertingTreesAmount = updatedTreeGroup.count
            
            /// If there are no changes combined tree should be placed as the last
            let finalTreeGroup = (afterInsertingTreesAmount == beforeInsertingTreesAmount) ? updatedTreeGroup + [combinedTree] : updatedTreeGroup
            return simplify(finalTreeGroup)
        }
    }
}

class Node {
    /// Values for building tree
    let quantity: Int
    
    /// Values for the decoding/encoding
    let symbol: String
    var digit: Int?
    
    var leftChild: Node?
    var rightChild: Node?
    
    init(value: String, quantity: Int) {
        self.quantity = quantity
        self.symbol = value
    }
    
    func join(anotherNode: Node) -> Node {
        let parentNodeValue = self.symbol + anotherNode.symbol
        let parentNodeQuantity = self.quantity + anotherNode.quantity
        let parentNode = Node(value: parentNodeValue, quantity: parentNodeQuantity)
        parentNode.leftChild = (self.quantity <= anotherNode.quantity) ? self : anotherNode
        parentNode.rightChild = (self.quantity > anotherNode.quantity) ? self : anotherNode
        return parentNode
    }
}

class HaffmanTree {
    let root: Node
    
    func description() -> String {
        return root.symbol
    }
    
    init(root: Node) {
        self.root = root
    }
    
    func join(node: Node) -> HaffmanTree {
        let rootNode = self.root.join(node)
        return HaffmanTree(root: rootNode)
    }
    
    func join(anotherTree: HaffmanTree) -> HaffmanTree {
        let rootNode = self.root.join(anotherTree.root)
        return HaffmanTree(root: rootNode)
    }
    
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