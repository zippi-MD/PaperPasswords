//
//  Alerts.swift
//  PPP-Crypto-Proyect
//
//  Created by Alejandro Mendoza on 26/01/20.
//  Copyright © 2020 Alejandro Mendoza. All rights reserved.
//

import UIKit

func createSimpleErrorAlertWith(message: String) -> UIAlertController {
    let ac = UIAlertController(title: "Ups :/", message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "Ok", style: .default)
    
    ac.addAction(action)
    
    return ac
}


func createSimpleSuccessAlertWith(message: String) -> UIAlertController {
    let ac = UIAlertController(title: "Yei :)", message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "Ok", style: .default)
    
    ac.addAction(action)
    
    return ac
}
