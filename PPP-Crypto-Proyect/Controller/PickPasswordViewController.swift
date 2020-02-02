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
    
    let cardsManager = Cards.sharedInstance
    
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
    
    @IBAction func saveRestoreButtonTapped(_ sender: Any) {
        
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
            selectedColumn = Cards.sharedInstance.columns[row]
        case .Rows:
            selectedRow = row
        }
        
        selectedPassword = SelectedPassword(card: selectedCard, column: selectedColumn, row: selectedRow)
        
    }
    
    
    
}



