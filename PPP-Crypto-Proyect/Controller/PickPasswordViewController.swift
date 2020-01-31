//
//  PickPasswordViewController.swift
//  PPP-Crypto-Proyect
//
//  Created by Alejandro Mendoza on 26/01/20.
//  Copyright © 2020 Alejandro Mendoza. All rights reserved.
//

import UIKit

enum PickPaperPasswordState {
    case GenerateCards
    case ShowCards
}

class PickPasswordViewController: UIViewController {

    @IBOutlet weak var getPasswordButton: UIButton! {
        didSet {
            getPasswordButton.layer.borderWidth = 2
            getPasswordButton.layer.borderColor = UIColor.systemBlue.cgColor
            getPasswordButton.layer.cornerRadius = 4.0
        }
    }
    @IBOutlet weak var passwordPickerView: UIPickerView!
    @IBOutlet weak var passwordPositionLabel: UITextField!
    @IBOutlet weak var passwordValueLabel: UITextField!
    @IBOutlet weak var generateCardsButton: UIButton!
    @IBOutlet weak var passwordContainerStackView: UIStackView!
    @IBOutlet weak var saveRestoreButton: UIBarButtonItem!
    
    var cards: [[String: [String]]]? {
        willSet {
            if let _ = newValue {
                storedCardsState = .CardsToStore
            }
        }
    }
    
    var selectedCard = 0
    var selectedColumn = "A"
    var selectedRow = 0
    
    var selectedPassword: SelectedPassword? {
        willSet {
            passwordPositionLabel.text = newValue?.description
        }
    }
    
    var storedCardsState: StoredCards = .NoStoredCards {
        willSet {
            switch newValue {
            case .NoStoredCards:
                saveRestoreButton.title = ""
            case .StoredCards:
                saveRestoreButton.title = "Restore Cards"
            case .CardsToStore:
                saveRestoreButton.title = "Save Cards"
            }
        }
    }
    
    var storedCardsEncrypted: String? {
        willSet {
            if let _ = newValue {
                storedCardsState = .StoredCards
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordPickerView.dataSource = self
        passwordPickerView.delegate = self
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        storedCardsEncrypted = getStoredCards()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let cards = Cards.sharedInstance.cards {
            self.cards = cards
            updateUITo(.ShowCards)
        }
        else {
            updateUITo(.GenerateCards)
        }
        
    }
    
    
    @IBAction func getPasswordTapped(_ sender: UIButton) {
        
        if let cards = cards,
           let selection = selectedPassword,
           let paperPassword = cards[selection.card][selection.column]?[selection.row] {
            
            passwordValueLabel.text = paperPassword
            
        }
        else {
            passwordValueLabel.text = ""
        }
        
    }
    
    @IBAction func saveRestoreButtonTapped(_ sender: Any) {
        switch storedCardsState {
        case .NoStoredCards:
            return
        case .CardsToStore:
            let alertUserPassword = UIAlertController(title: "PIN", message: "Write your pin to encrypt your cards", preferredStyle: .alert)
            alertUserPassword.addTextField()
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            let encriptAction = UIAlertAction(title: "Encrypt", style: .default) { [unowned self] (_) in
                guard let alertTextField = alertUserPassword.textFields?[0], let userPin = alertTextField.text, let cards = self.cards else { return }
                
                if let cipheredCardsBase64 = cypherCardsFrom(cards, with: userPin){
                    storeCardsIntoDocuments(cipheredCardsBase64)
                    self.storedCardsState = .NoStoredCards
                }
                
            }
            alertUserPassword.addAction(cancelAction)
            alertUserPassword.addAction(encriptAction)
            present(alertUserPassword, animated: true)
        case .StoredCards:
            let alertUserPassword = UIAlertController(title: "PIN", message: "Write your pin to decrypt your cards", preferredStyle: .alert)
            alertUserPassword.addTextField()
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            let decriptAction = UIAlertAction(title: "Decrypt", style: .default) { [unowned self] (_) in
                guard let alertTextField = alertUserPassword.textFields?[0], let userPin = alertTextField.text, let storedEncryptedCards = self.storedCardsEncrypted else { return }
                
                if let decryptedCards = decryptCardsFrom(storedEncryptedCards, with: userPin) {
                    self.cards = decryptedCards
                    self.updateUITo(.ShowCards)
                }
                
                
            }
            
            alertUserPassword.addAction(cancelAction)
            alertUserPassword.addAction(decriptAction)
            
            present(alertUserPassword, animated: true)
        }
    }
    
    
    
    
}

//MARK: UI
extension PickPasswordViewController {
    func updateUITo(_ stateToShow: PickPaperPasswordState){
        switch stateToShow {
        case .GenerateCards:
            generateCardsButton.isHidden = false
            passwordPositionLabel.isHidden = true
            passwordContainerStackView.isHidden = true
            passwordPickerView.isHidden = true
            getPasswordButton.isHidden = true
        case .ShowCards:
            generateCardsButton.isHidden = true
            passwordPositionLabel.isHidden = false
            passwordContainerStackView.isHidden = false
            passwordPickerView.isHidden = false
            getPasswordButton.isHidden = false
            selectedPassword = SelectedPassword(card: 0, column: Cards.sharedInstance.columns[0], row: 0)
            passwordPickerView.reloadAllComponents()
        }
    }
}

//MARK: Picker DataSource
extension PickPasswordViewController: UIPickerViewDataSource {
    
    enum PickerSections: Int {
        case Cards = 0
        case Columns
        case Rows
    }
    
    struct SelectedPassword: CustomStringConvertible {
        let card: Int
        let column: String
        let row: Int
        
        var description: String {
            return "Card - \(self.card + 1) Column - \(column) Row - \(self.row)"
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if let _ = cards {
            return 3
        }
        else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let cards = cards, let section = PickerSections(rawValue: component) else { return 0 }
        
        switch section {
        case .Cards:
            return cards.count
        case .Columns:
            return Cards.sharedInstance.columns.count
        case .Rows:
            return Cards.sharedInstance.numberOfRows
        }
    }
      
}

//MARK: PickerView Delegate
extension PickPasswordViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let section = PickerSections(rawValue: component) else { return nil }
        
        switch section {
        case .Cards:
            return "Card - \(row + 1)"
            
        case .Columns:
            guard let _ = cards else { return nil }
            return Cards.sharedInstance.columns[row]
        case .Rows:
            return "\(row)"
        }
       
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        guard let selectedComponent = PickerSections(rawValue: component) else { return }
        
        switch selectedComponent {
        case .Cards:
            selectedCard = row
        case .Columns:
            selectedColumn = Cards.sharedInstance.columns[row]
        case .Rows:
            selectedRow = row
        }
        
        selectedPassword = SelectedPassword(card: selectedCard, column: selectedColumn, row: selectedRow)
        
    }
    
    
    
}



