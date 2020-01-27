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
