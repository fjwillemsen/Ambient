//
//  zHome.swift
//  AmbiMac
//
//  Created by Floris-Jan Willemsen on 29-04-17.
//  Copyright © 2017 Floris-Jan Willemsen. All rights reserved.
//

import Cocoa

class zHome: NSViewController {
    
    @IBOutlet var ipAddressLabel: NSTextField!
    @IBOutlet var macAddressLabel: NSTextField!
    @IBOutlet var lightPicker: NSPopUpButton!
    var lightController :zAmbiLightController = zAmbiLightController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationManager = PHNotificationManager.default()
        // Register for the local heartbeat notifications
        notificationManager?.register(self, with: #selector(zHome.localConnection), forNotification: LOCAL_CONNECTION_NOTIFICATION)
        
        notificationManager?.register(self, with: #selector(zHome.noLocalConnection), forNotification: NO_LOCAL_CONNECTION_NOTIFICATION)
        
        loadConnectedBridgeValues()
        lightPicker.removeAllItems()
        loadLights()
    }
    
    func localConnection() {
        loadConnectedBridgeValues()
    }
    
    func noLocalConnection() {
        
    }
    
    func loadConnectedBridgeValues() {
        let cache = PHBridgeResourcesReader.readBridgeResourcesCache()
        
        // Check if we have connected to a bridge before
        if cache?.bridgeConfiguration?.ipaddress != nil {
            // Set the ip address of the bridge
            ipAddressLabel?.stringValue = cache!.bridgeConfiguration!.ipaddress
            
            // Set the mac adress of the bridge
            macAddressLabel?.stringValue = cache!.bridgeConfiguration!.mac
            
        }
    }
    
    func loadLights() {
        let cache = PHBridgeResourcesReader.readBridgeResourcesCache()
        
        for light in cache!.lights!.values {
            let light = light as! PHLight
            lightPicker.addItem(withTitle: light.name)
        }
    }
    
    func findLight(name :String) -> PHLight? {
        let cache = PHBridgeResourcesReader.readBridgeResourcesCache()
        for light in cache!.lights!.values {
            let light = light as! PHLight
            if light.name == name {
                return light
            }
        }
        
        return nil
    }
    
    @IBAction func startAmbilight(_ sender: Any) {
        let light = findLight(name: (lightPicker.selectedItem?.title)!)
        if light != nil {
            lightController.addLight(light: light!)
        }
    }
    
    @IBAction func stopAmbilight(_ sender: Any) {
        let light = findLight(name: (lightPicker.selectedItem?.title)!)
        if light != nil {
            lightController.removeLight(rlight: light!)
        }
    }
}
