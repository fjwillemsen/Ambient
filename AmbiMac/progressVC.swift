//
//  progressVC.swift
//  AmbiMac
//
//  Created by Floris-Jan Willemsen on 27-04-17.
//  Copyright © 2017 Floris-Jan Willemsen. All rights reserved.
//

import Cocoa

class progressVC: NSViewController {

    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        progressIndicator.startAnimation(self)
    }
    
}
