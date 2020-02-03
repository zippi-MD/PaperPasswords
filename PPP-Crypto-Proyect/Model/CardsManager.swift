//
//  Cards.swift
//  PPP-Crypto-Proyect
//
//  Created by Alejandro Mendoza on 26/01/20.
//  Copyright © 2020 Alejandro Mendoza. All rights reserved.
//

import UIKit
import CryptoKit

enum StoredCards {
    case NoStoredCards
    case StoredCards
    case CardsToStore
}

typealias Card = [String: [String]]

protocol CardsManagerDelegate {
    var numberOfCards: Int { get }
    var numberOfRows: Int { get }
    var columns: [String] { get }
    var characterSet: [String] { get }
    var passcodeLength: Int { get }
    var sequenceSymmetricKey: String { get }
    var cards: [Card]? { get }
    var storedCardsState: StoredCards { get }
    
    func generateCards(configuration: CardsConfiguration?)
    func getNewSequenceKey() -> String
    func storeCardsWithPin(_ pin: String)
    func recoverCardsWithPin(_ pin: String)
}

protocol CardsConfiguratorDelegate: class {
    func didFinishedGeneratingCards()
}

protocol PasswordPickerDelegate: class {
    func didFinishStoringCards(success: Bool)
    func didFinishDecryptingCards(success: Bool)
}

class CardsManager: CardsManagerDelegate {
    
    static let sharedInstance = CardsManager()
    
    private var sequenceKey: SymmetricKey
    private var temporalSequenceKey: SymmetricKey?
    private var counter: UInt128 = 0
    private var storedEncryptedCards: String?
    private let sequenceKeyKeychainKey = "SequenceKey"
    private let passwordCharacterSetKey = "characterSetKey"
    private let passwordLengthKey = "passcodedLengthKey"
    private let numberOfCardsKey = "numberOfCardsKey"
    private var cardsConfiguration = CardsConfiguration(numberOfCards: 4, passcodeLength: 4, characterSet: ["a","b","c"])
    
    let suggestedPasswordCharacters = "!#%+23456789:=?@ABCDEFGHJKLMNPRSTUVWXYZabcdefghijkmnopqrstuvwxyz"

    weak var cardsConfigurator: CardsConfiguratorDelegate?
    weak var passwordPicker: PasswordPickerDelegate?
    
    var numberOfCards: Int {
        get { cardsConfiguration.numberOfCards }
    }
    
    var numberOfRows: Int {
        get { cardsConfiguration.numberOfRows }
    }
    
    var columns: [String] {
        get { cardsConfiguration.columns }
    }
    
    var characterSet: [String] {
        get { cardsConfiguration.characterSet }
    }
    
    var passcodeLength: Int {
        get { cardsConfiguration.passcodeLength }
    }
    
    var sequenceSymmetricKey: String {
        get { getStringForKey(sequenceKey) }
    }
    
    private(set) var cards: [Card]?
    private(set) var storedCardsState: StoredCards = .NoStoredCards
    
    
    init() {
        
        if  let keyBase64 = KeychainWrapper.standard.string(forKey: sequenceKeyKeychainKey),
            let storedKey = getKeyFromBase64String(keyBase64) {
            sequenceKey = storedKey
        }
        else {
            sequenceKey = generateSequenceKey()
        }
        
        if let storedEncryptedCards = getStoredCards() {
            self.storedEncryptedCards = storedEncryptedCards
            self.storedCardsState = .StoredCards
        }
        else {
            self.storedCardsState = .NoStoredCards
        }
        
        self.cardsConfiguration = getUserCardsConfiguration()
    }
    
    func generateCards(configuration: CardsConfiguration?) {
        if let newConfiguration = configuration {
            self.cardsConfiguration = newConfiguration
        }
        
        if let newSequenceKey = temporalSequenceKey {
            self.sequenceKey = newSequenceKey
        }
        
        counter = 0
        self.cards = [Card]()
        
        for _ in 1...numberOfCards {
            var card = Card()
            
            for columnIndex in 0..<columns.count {
                var column = [String]()
                
                for _ in 0..<numberOfRows {
                    let cell = getCellPassword()
                    column.append(cell)
                }
                
                card[columns[columnIndex]] = column
            }
            
            self.cards?.append(card)
        }
        
        storedCardsState = .CardsToStore
        saveUserCardsConfiguration()
        cardsConfigurator?.didFinishedGeneratingCards()
    }
    
    func getNewSequenceKey() -> String {
        temporalSequenceKey = generateSequenceKey()
        guard let newKey = temporalSequenceKey else { return "" }
        return getStringForKey(newKey)
    }
    
    func storeCardsWithPin(_ pin: String){
        guard let cardsToStore = self.cards else {
            passwordPicker?.didFinishStoringCards(success: false)
            return
        }
        if let cipheredCardsBase64 = cypherCardsFrom(cardsToStore, with: pin){
            storeCardsIntoDocuments(cipheredCardsBase64)
            self.storedCardsState = .NoStoredCards
            passwordPicker?.didFinishStoringCards(success: true)
            return
        }
        passwordPicker?.didFinishStoringCards(success: false)
    }
    
    func recoverCardsWithPin(_ pin: String) {
        guard let storedCards = self.storedEncryptedCards else {
            passwordPicker?.didFinishDecryptingCards(success: false)
            return
        }
        if let decryptedCards = decryptCardsFrom(storedCards, with: pin) {
            self.cards = decryptedCards
            self.storedEncryptedCards = nil
            self.storedCardsState = .NoStoredCards
            passwordPicker?.didFinishDecryptingCards(success: true)
            return
        }
        passwordPicker?.didFinishDecryptingCards(success: false)
    }
    
    private func getUserCardsConfiguration() -> CardsConfiguration {
        let userDefaults = UserDefaults.standard
        
        let characterSet: [String]
        if let storedCharacterSet = userDefaults.array(forKey: passwordCharacterSetKey) as? [String] {
            characterSet = storedCharacterSet
        }
        else {
            characterSet = getCharacterArrayFrom(suggestedPasswordCharacters) ?? ["a", "b", "c"]
        }
        
        let passcodeLength: Int
        let storedPasscodeLength = userDefaults.integer(forKey: passwordLengthKey)
        passcodeLength = storedPasscodeLength > 0 ? storedPasscodeLength : 4
        
        let numberOfCards: Int
        let storedNumberOfCards = userDefaults.integer(forKey: numberOfCardsKey)
        numberOfCards = storedNumberOfCards > 0 ? storedNumberOfCards : 4
        
        return CardsConfiguration(numberOfCards: numberOfCards, passcodeLength: passcodeLength, characterSet: characterSet)
    }
    
    private func getCypheredCounter128Bit(_ counter: UInt128, using key: SymmetricKey) -> UInt128? {
        let counter128Bytes = get128bitCounterDataFrom(counter)
        
        guard let cypheredCounter128Bytes = try? AES.GCM.seal(counter128Bytes, using: key) else {
            assert(true, "Error cyphering counter")
            return nil
        }
        
        let cypheredCounter128Bits = ([UInt8](cypheredCounter128Bytes.ciphertext)).map { (0..<127).contains($0) ? "0" : "1" }
        
        return try? UInt128("0b"+cypheredCounter128Bits.joined())
    }
    
    
    private func getCellPassword() -> String {
        var cell = ""
        for _ in 0..<passcodeLength {
            
            let ciphered128BitCounter = getCypheredCounter128Bit(counter, using: sequenceKey) ?? UInt128()
            counter += 1
            
            let characterToAssign = ciphered128BitCounter % UInt128(characterSet.count)
            let characterIndex = Int(characterToAssign)
            cell = cell + characterSet[characterIndex]
        }
        
        return cell
    }
    
    private func saveUserCardsConfiguration(){
        let keyDataBase64 = getStringForKey(sequenceKey)
        KeychainWrapper.standard.set(keyDataBase64, forKey: sequenceKeyKeychainKey)
        
        UserDefaults.standard.set(cardsConfiguration.passcodeLength, forKey: passwordLengthKey)
        UserDefaults.standard.set(cardsConfiguration.numberOfCards, forKey: numberOfCardsKey)
        UserDefaults.standard.set(cardsConfiguration.characterSet, forKey: passwordCharacterSetKey)
    }
}
