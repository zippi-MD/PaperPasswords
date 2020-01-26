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
