//
//  CharacterSet.swift
//  PPP-Crypto-Proyect
//
//  Created by Alejandro Mendoza on 26/01/20.
//  Copyright © 2020 Alejandro Mendoza. All rights reserved.
//

import Foundation

func getCharacterArrayFrom(_ characters: String) -> [String]? {
    let values = characters.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "")
    
    if values != "" {
        return Array(Set(values)).map({String($0)}).sorted()
    }
    else {
        return nil
    }
    
}
