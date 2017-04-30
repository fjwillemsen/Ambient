//
//  connectBridge.swift
//  AmbiMac
//
//  Created by Floris-Jan Willemsen on 27-04-17.
//  Copyright © 2017 Floris-Jan Willemsen. All rights reserved.
//

import Cocoa

class connectBridge: NSViewController {

    @IBOutlet weak var bridge1button: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func showBridges(bridges :Dictionary<String, String>) {
        if bridges.count < 1 {
            bridge1button.title = "No bridges found"
        } else if bridges.count == 1 {
            bridge1button.title = (bridges.first?.value)!
        } else {
            bridge1button.title = "Number of bridges found: \(bridges.count)."
        }
    }
    
}
