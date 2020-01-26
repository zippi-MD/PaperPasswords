//
//  ConfigureViewController.swift
//  PPP-Crypto-Proyect
//
//  Created by Alejandro Mendoza on 26/01/20.
//  Copyright © 2020 Alejandro Mendoza. All rights reserved.
//

import UIKit
import CryptoKit

class ConfigureViewController: UIViewController {

    @IBOutlet weak var sequenceKeyLabel: UILabel!
    @IBOutlet weak var generateSequenceKeyButton: UIButton!
    @IBOutlet weak var generateCardsButton: UIButton!
    @IBOutlet weak var passwordCharacterSetTextView: UITextView!
    @IBOutlet weak var passwordLength: UILabel!
    
    var sequenceKey: SymmetricKey?
    
    let suggestedPasswordCharacterSet = "!#%+23456789:=?@ABCDEFGHJKLMNPRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI(){
        passwordCharacterSetTextView.text = suggestedPasswordCharacterSet
    }
    

    @IBAction func generateKeyTapped(_ sender: UIButton) {
        sequenceKey = generateSequenceKey()
        sequenceKeyLabel.text = sequenceKey?.withUnsafeBytes { Data(Array($0)).base64EncodedString() }
    }
    
    @IBAction func changePasswordLengthTapped(_ sender: UIStepper) {
        passwordLength.text = "\(Int(sender.value))"
    }
    
}
