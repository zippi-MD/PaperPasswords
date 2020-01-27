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
