//
//  HaffmanTree.swift
//  HaffmanCoding
//
//  Created by Yury Lapitsky on 12/9/15.
//  Copyright © 2015 skyylex. All rights reserved.
//

import Foundation

/// Phase 1. Get source string and save it
/// Phase 2. Parse source string into characters
/// Phase 3. Calculate quantity of the each symbols in the text
/// Phase 4. Build HaffmanTree
/// Phase 5. Create encoding map
/// Phase 6. Encode text using created tree

public class HaffmanTreeBuilder {
    public typealias DistributionMap = [Int : [Character]]
    public typealias ReverseDistributionMap = [Character : Int]
    
    public let text: String
    
    public init(text: String) {
        self.text = text
    }
    
    public func generateDistribution() -> DistributionMap {
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
    
    public func buildTree() -> HaffmanTree? {
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
    
    private func digitize(node: Node?) {
        if let aliveNode = node {
            aliveNode.leftChild?.digit = 0
            aliveNode.rightChild?.digit = 1
            
            digitize(aliveNode.leftChild)
            digitize(aliveNode.rightChild)
        }
    }

    private func simplify(trees: [HaffmanTree]) -> [HaffmanTree] {
        /// print(trees.map { $0.root.symbol } )
        if trees.count == 1 {
            return trees
        } else {
            let first = trees[0], second = trees[1]
            let combinedTree = first.join(second)
            let partedTrees = (trees.count > 2) ? Array(trees[2...(trees.count - 1)]) : [HaffmanTree]()
            
            let beforeInsertingTreesAmount = partedTrees.count
            var insertPosition = 0
            for nextTree in partedTrees {
                if (combinedTree.root.quantity < nextTree.root.quantity) {
                    break
                } else {
                    insertPosition += 1
                }
            }
            var updatedTreeGroup = partedTrees
            updatedTreeGroup.insert(combinedTree, atIndex: insertPosition)
            let afterInsertingTreesAmount = updatedTreeGroup.count
            
            /// If there are no changes combined tree should be placed as the last
            let finalTreeGroup = (afterInsertingTreesAmount == beforeInsertingTreesAmount) ? updatedTreeGroup + [combinedTree] : updatedTreeGroup
            return simplify(finalTreeGroup)
        }
    }
}

public class Node {
    /// Values for building tree
    public let quantity: Int
    
    /// Values for the decoding/encoding
    public let symbol: String
    public var digit: Int?
    
    public var leftChild: Node?
    public var rightChild: Node?
    
    public var isLeaf: Bool {
        return self.rightChild == nil && self.leftChild == nil
    }
    
    public init(value: String, quantity: Int) {
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

public class HaffmanTree {
    public let root: Node
    
    public func description() -> String {
        return root.symbol
    }
    
    public func validate() -> Bool {
        var validationResult = true
        let decodingMap = generateDecodingMap()
        for key1 in decodingMap.keys {
            for key2 in decodingMap.keys {
                if key1 == key2 {
                    continue
                } else if key1.hasPrefix(key2) == true {
                    print(key1 + " contains " + key2)
                    validationResult = false
                }
            }
        }
        
        return validationResult
    }
    
    public init(root: Node) {
        self.root = root
    }
    
    public func join(node: Node) -> HaffmanTree {
        let rootNode = self.root.join(node)
        return HaffmanTree(root: rootNode)
    }
    
    func join(anotherTree: HaffmanTree) -> HaffmanTree {
        let rootNode = self.root.join(anotherTree.root)
        return HaffmanTree(root: rootNode)
    }
    
    public func generateDecodingMap() -> [String: Character] {
        return generateEncodingMap().reduce([String: Character]()) { current, next -> [String: Character] in
            let symbol = next.0
            let string = next.1
            return current.join([string : symbol])
        }
    }
    
    public func generateEncodingMap() -> [Character: String] {
        return generateEncodingMap(self.root, digitString: "")
    }
    
    private func generateEncodingMap(node: Node?, digitString: String) -> [Character : String] {
        let encodingMap = [Character:String]()
        
        if let aliveNode = node {
            var updatedDigitString = digitString
            
            if let symbol = aliveNode.symbol.characters.first, digit = aliveNode.digit {
                updatedDigitString += String(digit)
                
                if aliveNode.isLeaf {
                    return [symbol : updatedDigitString]
                }
            }
            
            let leftPartResults = generateEncodingMap(aliveNode.leftChild, digitString:updatedDigitString)
            let rightPartResults = generateEncodingMap(aliveNode.rightChild, digitString:updatedDigitString)
            let result = encodingMap.join(leftPartResults).join(rightPartResults)
            
            return result
        }
        
        return encodingMap
    }
}

