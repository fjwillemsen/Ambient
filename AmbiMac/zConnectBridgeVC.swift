//
//  zConnectBridgeVC.swift
//  AmbiMac
//
//  Created by Floris-Jan Willemsen on 28-04-17.
//  Copyright © 2017 Floris-Jan Willemsen. All rights reserved.
//

import Cocoa

protocol PHBridgeSelectionViewControllerDelegate {
    func bridgeSelectedWithIpAddress(ipAddress: String, bridgeId: String)
}

class zConnectBridgeVC: NSViewController {
    
    @IBOutlet var bridgeInfo: NSTextField!
    @IBOutlet var bridgePicker: NSPopUpButton!
    
    var delegate: PHBridgeSelectionViewControllerDelegate?
    var bridges :Dictionary<String, String> = Dictionary<String, String>()
    var ipAddress :String = "0"
    var bridgeId :String = "0"

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showAvailableBridges(availableBridges :Dictionary<String, String>) {
        bridges = availableBridges
        bridgePicker.removeAllItems()
        
        if bridges.count < 1 {
            bridgeInfo.stringValue = "No bridges were found on the network."
        } else {
            for bridge in Array(bridges.values) {
                bridgePicker.addItem(withTitle: "\(bridge)")
            }
        }
    }
    
    
    @IBAction func pickerClicked(_ sender: Any) {
        let ids = Array(bridges.keys)
        ipAddress = bridgePicker.selectedItem!.title
        bridgeId = ids[bridgePicker.indexOfItem(withTitle: bridgePicker.selectedItem!.title)]
    }
    
    @IBAction func connectButtonClicked(_ sender: Any) {
        let ids = Array(bridges.keys)
        ipAddress = bridgePicker.selectedItem!.title
        bridgeId = ids[bridgePicker.indexOfItem(withTitle: bridgePicker.selectedItem!.title)]
        delegate!.bridgeSelectedWithIpAddress(ipAddress: ipAddress, bridgeId: bridgeId)
    }
    
}
