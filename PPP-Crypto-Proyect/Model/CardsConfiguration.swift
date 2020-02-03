//
//  CardsConfigurator.swift
//  PPP-Crypto-Proyect
//
//  Created by Alejandro Mendoza on 02/02/20.
//  Copyright © 2020 Alejandro Mendoza. All rights reserved.
//

import Foundation

struct CardsConfiguration {
    let numberOfCards: Int
    let numberOfRows: Int = 10
    let passcodeLength: Int
    let characterSet: [String]
    let columns: [String]  = ["A", "B", "C", "D", "E", "F", "G"]
}
