//
//  ConfigureViewController.swift
//  PPP-Crypto-Proyect
//
//  Created by Alejandro Mendoza on 26/01/20.
//  Copyright © 2020 Alejandro Mendoza. All rights reserved.
//

import UIKit

class ConfigureViewController: UIViewController {

    @IBOutlet weak var sequenceKeyLabel: UILabel!
    @IBOutlet weak var generateSequenceKeyButton: UIButton!
    @IBOutlet weak var setSuggestedCharacterSetButton: UIButton!
    @IBOutlet weak var generateCardsButton: UIButton!
    @IBOutlet weak var passwordCharacterSetTextView: UITextView!
    @IBOutlet weak var passwordLength: UILabel!
    @IBOutlet weak var numberOfCardsLabel: UILabel!
    @IBOutlet weak var passwordLengthStepper: UIStepper!
    @IBOutlet weak var numberOfCardsStepper: UIStepper!
    @IBOutlet weak var backgroundScrollView: UIScrollView!
    
    weak var pickPasswordViewController: PickPasswordViewController?
    
    var cardsManager: CardsManager = CardsManager.sharedInstance
    
    var sequenceKey: String? {
        willSet {
            sequenceKeyLabel.text = newValue
        }
    }
    var passcodeLength: Int = 4 {
        willSet {
            passwordLength.text = "\(newValue)"
            passwordLengthStepper.value = Double(newValue)
        }
    }
    var numberOfCards: Int = 3 {
        willSet {
            numberOfCardsLabel.text = "\(newValue)"
            numberOfCardsStepper.value = Double(newValue)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardsManager.cardsConfigurator = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        passcodeLength = cardsManager.passcodeLength
        numberOfCards = cardsManager.numberOfCards
        sequenceKey = cardsManager.sequenceSymmetricKey
        passwordCharacterSetTextView.text = cardsManager.suggestedPasswordCharacters
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        pickPasswordViewController?.reloadData()
    }
    

    @IBAction func generateKeyTapped(_ sender: UIButton) {
        sequenceKey = cardsManager.getNewSequenceKey()
    }
    
    @IBAction func changePasswordLengthTapped(_ sender: UIStepper) {
        passcodeLength = Int(sender.value)
    }
    
    @IBAction func changeNumberOfCardsToGenerate(_ sender: UIStepper) {
        numberOfCards = Int(sender.value)
    }
    
    @IBAction func restoreSuggestedCharacterSet(_ sender: Any) {
        passwordCharacterSetTextView.text = cardsManager.suggestedPasswordCharacters
    }
    
    @IBAction func generateCardsTapped(_ sender: UIButton) {
        
        guard let characterArray = getCharacterArrayFrom(passwordCharacterSetTextView.text) else {
            present(createSimpleErrorAlertWith(message: "The character set is not valid"), animated: true)
            return
        }
        
        generateCardsButton.isEnabled = false
        numberOfCardsStepper.isEnabled = false
        passwordLengthStepper.isEnabled = false
        generateSequenceKeyButton.isEnabled = false
        setSuggestedCharacterSetButton.isEnabled = false
        
        backgroundScrollView.contentInsetAdjustmentBehavior = .never
        
        self.isModalInPresentation = true
                
        let numberOfCards = Int(numberOfCardsStepper.value)
        let passcodeLength = Int(passwordLengthStepper.value)
        let newConfiguration = CardsConfiguration(numberOfCards: numberOfCards, passcodeLength: passcodeLength, characterSet: characterArray)
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .black
        activityIndicator.center = self.view.center
        activityIndicator.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        
        DispatchQueue.global(qos: .userInitiated).async {
            CardsManager.sharedInstance.generateCards(configuration: newConfiguration)
        }
        
    }
    
    
    
}


extension ConfigureViewController: CardsConfiguratorDelegate {
    func didFinishedGeneratingCards() {
        DispatchQueue.main.async {
            [unowned self] in
            self.dismiss(animated: true) {
                [unowned self] in
                self.pickPasswordViewController?.reloadData()
            }
        }
        
    }
    
    
}
