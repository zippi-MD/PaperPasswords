//
//  Cards.swift
//  PPP-Crypto-Proyect
//
//  Created by Alejandro Mendoza on 26/01/20.
//  Copyright © 2020 Alejandro Mendoza. All rights reserved.
//

import UIKit
import CryptoKit

enum StoredCards {
    case NoStoredCards
    case StoredCards
    case CardsToStore
}

class Cards {
    
    static let sharedInstance = Cards()
    private var sequenceKey: SymmetricKey?
    private var passcodeCharacterSet: [String]?
    private var passcodeLenght: Int?
    private var numberOfCards: Int?
    private var actualCounterValue: UInt = 0
    var numberOfRows: Int = 10
    var columns: [String] = ["A", "B", "C", "D", "E", "F", "G"]
    
    var cards: [ [String: [String]] ]?
    
    func generateCards(sequenceKey: SymmetricKey, passcodeCharacterSet: [String], passcodeLenght: Int, numberOfCards: Int) {
        self.sequenceKey = sequenceKey
        self.passcodeCharacterSet = passcodeCharacterSet
        self.passcodeLenght = passcodeLenght
        self.numberOfCards = numberOfCards
        
        self.cards = [[String: [String]]]()
        
        for _ in 1...numberOfCards {
            var card = [String: [String]]()
            
            for columnIndex in 0..<columns.count {
                var column = [String]()
                
                for _ in 0..<numberOfRows {
                    let cell = getCellPasswordWithLenght(passcodeLenght, fromCharacterSet: passcodeCharacterSet, withKey: sequenceKey)
                    column.append(cell)
                }
                
                card[columns[columnIndex]] = column
            }
            
            self.cards?.append(card)
        }
        
        
    }
    
    func getCypheredCounter128Bit(using key: SymmetricKey) -> String? {
        let counter = get128bitCounterDataFrom(actualCounterValue)
        actualCounterValue = actualCounterValue + 1
        
        guard let cypheredCounter = try? AES.GCM.seal(counter, using: key) else {
            assert(true, "Error cyphering counter")
            return nil
        }
        
        let simplified128Counter = ([UInt8](cypheredCounter.ciphertext)).map { value -> String in
            return (0..<127).contains(value) ? "0" : "1"
        }
        
        return Array(simplified128Counter[0..<(simplified128Counter.count/2)]).joined()
    }
    
    func getCellPasswordWithLenght(_ passwordLength: Int, fromCharacterSet characterSet: [String], withKey key: SymmetricKey) -> String {
        
        var cell = ""
        
        for _ in 0..<passwordLength {
            
            let ciphered128BitCounter = getCypheredCounter128Bit(using: key) ?? " "
            let ciphered128CounterValue = try! UInt128("0b"+ciphered128BitCounter)
            let characterToAssign = ciphered128CounterValue % UInt128(characterSet.count)
            let characterIndex = Int(characterToAssign)
            cell = cell + characterSet[characterIndex]
        }
        
        return cell
    }
}
