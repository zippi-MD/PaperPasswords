//
//  Documents.swift
//  PPP-Crypto-Proyect
//
//  Created by Alejandro Mendoza on 30/01/20.
//  Copyright © 2020 Alejandro Mendoza. All rights reserved.
//

import Foundation

func getStoredCards() -> String? {
    
    guard let documentDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else { return nil }
    
    let fileURL = documentDirectory.appendingPathComponent("cards.txt")
    
    if let cardsData = try? Data(contentsOf: fileURL) {
        return String(data: cardsData, encoding: .utf8)
    }
    else {
        return nil
    }
}

func storeCardsIntoDocuments(_ cardsBase64: String){
    guard let documentDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else { return }
    
    let fileURL = documentDirectory.appendingPathComponent("cards.txt")
    let _ = try? cardsBase64.write(to: fileURL, atomically: true, encoding: .utf8)
}
