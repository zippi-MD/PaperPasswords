//
//  PickPasswordViewController.swift
//  PPP-Crypto-Proyect
//
//  Created by Alejandro Mendoza on 26/01/20.
//  Copyright © 2020 Alejandro Mendoza. All rights reserved.
//

import UIKit

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
    @IBOutlet weak var passwordContainerStackView: UIStackView!
    @IBOutlet weak var saveRestoreButton: UIButton!
    
    let cardsManager: CardsManager = CardsManager.sharedInstance
    
    var selectedCard = 0
    var selectedColumn = "A"
    var selectedRow = 0
    
    var selectedPassword: SelectedPassword? {
        willSet {
            passwordPositionLabel.text = newValue?.description
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordPickerView.dataSource = self
        passwordPickerView.delegate = self
        cardsManager.passwordPicker = self
        
        updateSaveRestoreButtonTo(cardsManager.storedCardsState)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if cardsManager.cards == nil {
            askToGenerateOrRestoreCards()
        }
        
    }
    
    private func askToGenerateOrRestoreCards() {
        let alert = UIAlertController(title: "No cards", message: "You don't have cards, please restore or generate ones", preferredStyle: .alert)
        let generateAction = UIAlertAction(title: "Generate", style: .default) { [unowned self] (_) in
            self.performSegue(withIdentifier: "toGenerateCards", sender: nil)
        }
        
        alert.addAction(generateAction)
        
        if cardsManager.storedCardsState == .StoredCards {
            let restoreCardsAction = UIAlertAction(title: "Restore", style: .default) { [unowned self](_) in
                self.saveRestoreButtonTapped(nil)
            }
            alert.addAction(restoreCardsAction)
        }
        
        present(alert, animated: true)
    }
    
    func reloadData(){
        if let _ = cardsManager.cards {
            passwordPickerView.reloadAllComponents()
            selectedPassword = SelectedPassword(card: selectedCard, column: selectedColumn, row: selectedRow)
            updateSaveRestoreButtonTo(cardsManager.storedCardsState)
        }
        else {
            askToGenerateOrRestoreCards()
        }
    }
    
    @IBAction func getPasswordTapped(_ sender: UIButton) {
        
        if let cards = cardsManager.cards,
           let selection = selectedPassword,
           let paperPassword = cards[selection.card][selection.column]?[selection.row] {
            
            passwordValueLabel.text = paperPassword
            
        }
        else {
            passwordValueLabel.text = ""
        }
        
    }
    
    @IBAction func saveRestoreButtonTapped(_ sender: Any?) {
        switch cardsManager.storedCardsState {
        case .NoStoredCards:
            return
            
        case .CardsToStore:
            let alertUserPassword = UIAlertController(title: "PIN", message: "Write a pin to encrypt your cards", preferredStyle: .alert)
            alertUserPassword.addTextField()
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            let encriptAction = UIAlertAction(title: "Encrypt", style: .default) { [unowned self] (_) in
                guard let alertTextField = alertUserPassword.textFields?[0], let userPin = alertTextField.text else { return }
                
                DispatchQueue.global(qos: .background).async {
                    self.cardsManager.storeCardsWithPin(userPin)
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
                guard let alertTextField = alertUserPassword.textFields?[0], let userPin = alertTextField.text else { return }
                self.cardsManager.recoverCardsWithPin(userPin)
            }
            alertUserPassword.addAction(cancelAction)
            alertUserPassword.addAction(decriptAction)
            
            present(alertUserPassword, animated: true)
        }
    }
    
    
    
    
}

//MARK: Navigation
extension PickPasswordViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let configureViewController = segue.destination as? ConfigureViewController {
            configureViewController.pickPasswordViewController = self
        }
    }
}

//MARK: UI
extension PickPasswordViewController {
    private func updateSaveRestoreButtonTo(_ state: StoredCards){
        switch state {
        case .NoStoredCards:
            saveRestoreButton.setTitle("", for: .normal)
        case .CardsToStore:
            saveRestoreButton.setTitle("Save Cards", for: .normal)
        case .StoredCards:
            saveRestoreButton.setTitle("Restore Cards", for: .normal)
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
            return "Card: \(self.card + 1) - Column: \(column) - Row:\(self.row)"
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if let _ = cardsManager.cards {
            return 3
        }
        else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let cards = cardsManager.cards, let section = PickerSections(rawValue: component) else { return 0 }
        
        switch section {
        case .Cards:
            return cards.count
        case .Columns:
            return CardsManager.sharedInstance.columns.count
        case .Rows:
            return CardsManager.sharedInstance.numberOfRows
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
            guard let _ = cardsManager.cards else { return nil }
            return cardsManager.columns[row]
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
            selectedColumn = CardsManager.sharedInstance.columns[row]
        case .Rows:
            selectedRow = row
        }
        
        selectedPassword = SelectedPassword(card: selectedCard, column: selectedColumn, row: selectedRow)
        
    }
    
    
    
}

//MARK: PasswordPicker Delegate
extension PickPasswordViewController: PasswordPickerDelegate {
    func didFinishStoringCards(success: Bool) {
        let alertMessage: String
        alertMessage = success ? "The cards were stored successfully" : "An error ocurred while storing the cards"
        
        let alert = createSimpleSuccessAlertWith(message: alertMessage)
        
        DispatchQueue.main.async {
            [unowned self] in
            self.present(alert, animated: true)
        }
        
    }
    
    func didFinishDecryptingCards(success: Bool) {
        let alertMessage: String
        alertMessage = success ? "Cards decrypted successfully" : "Wrong pin"
        
        let alert = UIAlertController(title: "Decrypting", message: alertMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { [unowned self] (_) in
            self.reloadData()
        }
        
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}

