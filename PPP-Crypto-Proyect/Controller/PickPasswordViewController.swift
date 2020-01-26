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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
