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
    
    var sequenceKey: SymmetricKey? {
        willSet {
            if let key = newValue {
                sequenceKeyLabel.text = getStringForKey(key)
            }
        }
    }
    var passcodeLength: Int = 4 {
        willSet {
            passwordLength.text = "\(newValue)"
        }
    }
    var numberOfCards: Int = 3 {
        willSet {
            numberOfCardsLabel.text = "\(newValue)"
        }
    }
    
    let suggestedPasswordCharacterSet = "!#%+23456789:=?@ABCDEFGHJKLMNPRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
    
    let sequenceKeyKeychainKey = "SequenceKey"
    let passwordCharacterSetKey = "characterSetKey"
    let passwordLengthKey = "passcodedLengthKey"
    let numberOfCardsKey = "numberOfCardsKey"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI(){
        passwordCharacterSetTextView.text = suggestedPasswordCharacterSet
        
        if let keyBase64 = KeychainWrapper.standard.string(forKey: sequenceKeyKeychainKey), let storedKey = getKeyFromBase64String(keyBase64) {
            sequenceKey = storedKey
        }
        
        let userDefaults = UserDefaults.standard
        
        if let storedCharacterSet = userDefaults.array(forKey: passwordCharacterSetKey) as? [String] {
            passwordCharacterSetTextView.text = storedCharacterSet.joined()
        }
        
        let storedPasscodeLength = userDefaults.integer(forKey: passwordLengthKey)
        passcodeLength = storedPasscodeLength > 0 ? storedPasscodeLength : 4
        
        let storedNumberOfCards = userDefaults.integer(forKey: numberOfCardsKey)
        numberOfCards = storedNumberOfCards > 0 ? storedNumberOfCards : 4
        
    }
    

    @IBAction func generateKeyTapped(_ sender: UIButton) {
        let newKey = generateSequenceKey()
        sequenceKey = newKey
    }
    
    @IBAction func changePasswordLengthTapped(_ sender: UIStepper) {
        passcodeLength = Int(sender.value)
    }
    
    @IBAction func changeNumberOfCardsToGenerate(_ sender: UIStepper) {
        numberOfCards = Int(sender.value)
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
        
        let keyDataBase64 = getStringForKey(key)
        KeychainWrapper.standard.set(keyDataBase64, forKey: sequenceKeyKeychainKey)
        
        UserDefaults.standard.set(passcodeLength, forKey: passwordLengthKey)
        UserDefaults.standard.set(numberOfCards, forKey: numberOfCardsKey)
        UserDefaults.standard.set(characterArray, forKey: passwordCharacterSetKey)
        
        Cards.sharedInstance.generateCards(sequenceKey: key, passcodeCharacterSet: characterArray, passcodeLenght: passcodeLength, numberOfCards: numberOfCards)
    }
    
    
    
}
