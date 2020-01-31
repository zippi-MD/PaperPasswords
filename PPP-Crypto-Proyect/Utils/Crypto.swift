//
//  Crypto.swift
//  PPP-Crypto-Proyect
//
//  Created by Alejandro Mendoza on 26/01/20.
//  Copyright © 2020 Alejandro Mendoza. All rights reserved.
//

import Foundation
import CryptoKit

func generateSequenceKey() -> SymmetricKey{
    let keySize = SymmetricKeySize.bits256
    return SymmetricKey(size: keySize)
}

func cypherCounter(using key: SymmetricKey) {
    
}

func get128bitCounterDataFrom(_ value: UInt) -> Data {
    var counter = String(value, radix: 2)
    
    while counter.count < 128 {
        counter = "0" + counter
    }
    
    return Data(counter.utf8)
    
}

func getStringForKey(_ key: SymmetricKey) -> String {
    key.withUnsafeBytes { Data(Array($0)).base64EncodedString() }
}

func getKeyFromBase64String(_ base64Key: String) -> SymmetricKey? {
    if let keyData = Data(base64Encoded: base64Key) {
        return SymmetricKey(data: keyData)
    }
    return nil
}


func decryptCardsFrom(_ base64Cards: String, with pin: String) -> [[String: [String]]]? {
    guard let pinData = pin.data(using: .utf8) else { return nil}
    
    let hashedPin = SHA256.hash(data: pinData)
    let key = SymmetricKey(data: hashedPin)
    
    let jsonDecoder = JSONDecoder()
    
    if  let cardsData = Data(base64Encoded: base64Cards),
        let sealedBox = try? AES.GCM.SealedBox(combined: cardsData),
        let decryptedData = try? AES.GCM.open(sealedBox, using: key),
        let decodedCards = try? jsonDecoder.decode([[String: [String]]].self, from: decryptedData){

        return decodedCards
        
    }
    else {
        return nil
    }
}

func cypherCardsFrom(_ cards: [[String: [String]]], with pin: String) -> String? {
    guard let pinData = pin.data(using: .utf8) else { return nil}
    
    let hashedPin = SHA256.hash(data: pinData)
    let key = SymmetricKey(data: hashedPin)
    
    let jsonEncoder = JSONEncoder()
    
    if  let jsconCardsData = try? jsonEncoder.encode(cards),
        let sealedCards = try? AES.GCM.seal(jsconCardsData, using: key),
        let combinedData = sealedCards.combined {
        
        return combinedData.base64EncodedString()
    }
    else {
        return nil
    }
    
}
