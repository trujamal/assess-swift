//
//  TabBarScreenController.swift
//  Athena
//
//  Created by Aalap Patel on 9/14/18.
//  Copyright © 2018 Aalap Patel. All rights reserved.
//

import Foundation
import UIKit

class HomeController: UIViewController {
    
    //Declares button and view to perform camera segue
    @IBOutlet weak var camView: UIView!
    @IBOutlet weak var camButton: UIButton!
    
    //Declares button and view to perform segue to discover page
    @IBOutlet weak var discoverView: UIView!
    @IBOutlet weak var discoverButton: UIButton!
    
    //Delcares button and view to perform segue to the more page
    @IBOutlet weak var moreView: UIView!
    @IBOutlet weak var moreButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Takes all the button backgrounds and rounds them
        camView.layer.cornerRadius = camView.bounds.size.height/2
        camView.clipsToBounds = true
        discoverView.layer.cornerRadius = discoverButton.bounds.size.height/2
        discoverView.clipsToBounds = true
        moreView.layer.cornerRadius = moreButton.bounds.size.height/2
        moreView.clipsToBounds = true
        
    
       //Rounds all the buttons to match the backgrounds
        camButton.layer.cornerRadius = camButton.bounds.size.height/2
        camButton.clipsToBounds = true
        discoverButton.layer.cornerRadius = discoverButton.bounds.size.height/2
        discoverButton.clipsToBounds = true
        moreButton.layer.cornerRadius = moreButton.bounds.size.height/2
        moreButton.clipsToBounds = true
 
        
    }
    
    @IBAction func camPressed(_ sender: Any) {
        
        self.performSegue(withIdentifier: "toCam", sender: self)
    }
    
    
    @IBAction func discoverPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "toDiscover", sender: self)
        
    }
    
   
    
    
    
    
    
    
    

}
