//
//  welcomeVC.swift
//  AmbiMac
//
//  Created by Floris-Jan Willemsen on 28-04-17.
//  Copyright © 2017 Floris-Jan Willemsen. All rights reserved.
//

import Cocoa

class welcomeVC: NSViewController {

    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        progressIndicator.startAnimation(self)
    }
    
}
