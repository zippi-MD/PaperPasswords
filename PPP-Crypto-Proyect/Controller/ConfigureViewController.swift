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
    @IBOutlet weak var numberOfCardsLabel: UILabel!
    
    var sequenceKey: SymmetricKey?
    var passcodeLength: Int = 4
    var numberOfCards: Int = 3
    
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
        let length = Int(sender.value)
        passwordLength.text = "\(length)"
        passcodeLength = length
    }
    
    @IBAction func changeNumberOfCardsToGenerate(_ sender: UIStepper) {
        let senderNumberOfCards = Int(sender.value)
        numberOfCards = senderNumberOfCards
        numberOfCardsLabel.text = "\(numberOfCards)"
    }
    
    
    @IBAction func generateCardsTapped(_ sender: UIButton) {
        
        guard let key = sequenceKey else {
            present(createSimpleErrorAlertWith(message: "You need to generate a key first"), animated: true)
            return
        }
        
        guard let characterArray = getCharacterArrayFrom(passwordCharacterSetTextView.text) else {
            present(createSimpleErrorAlertWith(message: "The character set is not valid"), animated: true)
            return
        }
        
        Cards.sharedInstance.generateCards(sequenceKey: key, passcodeCharacterSet: characterArray, passcodeLenght: passcodeLength, numberOfCards: numberOfCards)
    }
    
    
    
}
