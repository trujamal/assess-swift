//
//  SettingsController.swift
//  Athena
//
//  Created by Aalap Patel on 9/15/18.
//  Copyright © 2018 Jamal Rasool. All rights reserved.
//

import UIKit
import UserNotifications

class SettingsController: UIViewController {
    
    
    
    @IBOutlet weak var goBackButton: UIButton!
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var mainScroll: UIScrollView!
    
    
    override func viewDidLoad(){
        super.viewDidLoad()

    }
    
    
    @IBAction func backPressed(_ sender: Any) {
        performSegue(withIdentifier: "setToHome", sender: self)
    }
    
    
    
}
