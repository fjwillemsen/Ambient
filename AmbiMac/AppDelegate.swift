//
//  AppDelegate.swift
//  AmbiMac
//
//  Created by Floris-Jan Willemsen on 26-04-17.
//  Copyright © 2017 Floris-Jan Willemsen. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let phHueSdk: PHHueSDK = PHHueSDK()
    let statusItem = NSStatusBar.system().statusItem(withLength: -2)
    let popover = NSPopover()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if let button = statusItem.button {
            let icon = NSImage(named: "statusIcon")
            icon?.isTemplate = true
            button.image = icon
            button.action = #selector(AppDelegate.togglePopover(_:))
        }
        
        popover.contentViewController = welcomeVC(nibName: "welcomeVC", bundle: nil)
        
        phHueSdk.startUp()
        phHueSdk.enableLogging(true)
        let notificationManager = PHNotificationManager.default()
        
        // The SDK will send the following notifications in response to events:
        //
        // - LOCAL_CONNECTION_NOTIFICATION
        // This notification will notify that the bridge heartbeat occurred and the bridge resources cache data has been updated
        //
        // - NO_LOCAL_CONNECTION_NOTIFICATION
        // This notification will notify that there is no connection with the bridge
        //
        // - NO_LOCAL_AUTHENTICATION_NOTIFICATION
        // This notification will notify that there is no authentication against the bridge
        
        notificationManager?.register(self, with: #selector(AppDelegate.localConnection) , forNotification: LOCAL_CONNECTION_NOTIFICATION)
        notificationManager?.register(self, with: #selector(AppDelegate.noLocalConnection), forNotification: NO_LOCAL_CONNECTION_NOTIFICATION)
        notificationManager?.register(self, with: #selector(AppDelegate.notAuthenticated), forNotification: NO_LOCAL_AUTHENTICATION_NOTIFICATION)
        
        enableLocalHeartbeat()
        
//        NSEvent.addGlobalMonitorForEvents(matching: NSEventMask.leftMouseUp, handler: closePopover)
//        NSEvent.addGlobalMonitorForEvents(matching: NSEventMask.rightMouseUp, handler: closePopover)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        disableLocalHeartbeat()
        
        // Remove any open popups
    }
    
    func showPopover(_ sender: AnyObject?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    
    func closePopover(_ sender: AnyObject?) {
        popover.performClose(sender)
    }
    
    func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }

    
    // MARK: - HueSDK
    
    /// Notification receiver for successful local connection
    func localConnection() {
        checkConnectionState()
    }
    
    
    /// Notification receiver for failed local connection
    func noLocalConnection() {
        checkConnectionState()
    }
    
    
    ///  Notification receiver for failed local authentication
    func notAuthenticated() {
        
        // We are not authenticated so we start the authentication process
        
        // Move to main screen (as you can't control lights when not connected)
        
        // Dismiss modal views when connection is lost
        
        // Remove no connection alert
        
        // Start local authenticion process
        let delay = 0.5 * Double(NSEC_PER_SEC)
        let time = DispatchTime.init(uptimeNanoseconds: UInt64(delay))
        DispatchQueue.main.asyncAfter(deadline: time) {
            self.doAuthentication()
        }
    }
    
    
    /// Checks if we are currently connected to the bridge locally and if not, it will show an error when the error is not already shown.
    func checkConnectionState() {
        
        if !phHueSdk.localConnected() {
            // Dismiss modal views when connection is lost

            
            // No connection at all, show connection popup
                
                // Showing popup, so remove this view

            // One of the connections is made, remove popups and loading views
            searchForBridgeLocal()
        } else {
            let vc = zHome.init(nibName: "zHome", bundle: nil)
            self.popover.contentViewController = vc
        }
    }
    
    
    /// Shows the first no connection alert with more connection options
    func showNoConnectionDialog() {
        self.searchForBridgeLocal()
        self.disableLocalHeartbeat()
    }
    
    
    // MARK: - Heartbeat control
    
    /// Starts the local heartbeat with a 10 second interval
    func enableLocalHeartbeat() {
        
        // The heartbeat processing collects data from the bridge so now try to see if we have a bridge already connected
        let cache = PHBridgeResourcesReader.readBridgeResourcesCache()
        if cache?.bridgeConfiguration?.ipaddress != nil {
            phHueSdk.enableLocalConnection()
        } else {
            searchForBridgeLocal()
        }
    }
    
    
    /// Stops the local heartbeat
    func disableLocalHeartbeat() {
        phHueSdk.disableLocalConnection()
    }
    
    
    // MARK: - Bridge searching
    
    /// Search for bridges using UPnP and portal discovery, shows results to user or gives error when none found.
    func searchForBridgeLocal() {
        
        popover.contentViewController = progressVC(nibName: "progressVC", bundle: nil)
        // Stop heartbeats
        disableLocalHeartbeat()
        
        // Show search screen
        
        // A bridge search is started using UPnP to find local bridges
        
        // Start search
        let bridgeSearch = PHBridgeSearching(upnpSearch: true, andPortalSearch: true, andIpAddressSearch: true)
        bridgeSearch?.startSearch(completionHandler: { (bridgesFound: Optional<Dictionary<AnyHashable, Any>>) -> () in
            let vc = zConnectBridgeVC.init(nibName: "zConnectBridgeVC", bundle: nil)
            self.popover.contentViewController = vc
            vc!.showAvailableBridges(availableBridges: bridgesFound as! Dictionary<String, String>)
            vc!.delegate = self
        
        } as PHBridgeSearchCompletionHandler )
        
//                // Done with search, remove loading view
//                
//                // The search is complete, check whether we found a bridge
//            
//                if bridgesFound.count > 0 {
//                    // Results were found, show options to user (from a user point of view, you should select automatically when there is only one bridge found)
//                    bridgesFound as! [String: String]
//                    
//                } else {
//                    // No bridge was found was found. Tell the user and offer to retry..
//                    
//                    self.searchForBridgeLocal()
//                    
//                    self.disableLocalHeartbeat()
//                }
//            
//            })
    }
    
    
    // MARK: - Bridge authentication
    
    /// Start the local authentication process
    func doAuthentication() {
        
        // To be certain that we own this bridge we must manually push link it. Here we display the view to do this.
        disableLocalHeartbeat()
        let vc = zLinkBridge.init(nibName: "zLinkBridge", bundle: nil)
        self.popover.contentViewController = vc
        vc!.phHueSdk = phHueSdk
        vc!.delegate = self
        vc!.startPushLinking()
    }
    
    
    // MARK: - Loading view
    
    /// Shows an overlay over the whole screen with a black box with spinner and loading text in the middle
    /// :param: text The text to display under the spinner
    func showLoadingViewWithText(text:String) {
        // First remove
        
        // Then add new
    }
    
    /// Removes the full screen loading overlay.
    func removeLoadingView() {
    }
}

//
//// MARK: - PHBridgeSelectionViewControllerDelegate
extension AppDelegate: PHBridgeSelectionViewControllerDelegate {
    
    /// Delegate method for BridgeSelectionViewController which is invoked when a bridge is selected
    func bridgeSelectedWithIpAddress(ipAddress:String, bridgeId: String) {
        // Removing the selection view controller takes us to the 'normal' UI view
        
        // Show a connecting view while we try to connect to the bridge
        
        // Set the username, ipaddress and mac address, as the bridge properties that the SDK framework will use
        //    phHueSdk.setBridgeToUseWithIpAddress(ipAddress, macAddress: macAddress)
        phHueSdk.setBridgeToUseWithId(bridgeId, ipAddress: ipAddress)
        
        // Setting the hearbeat running will cause the SDK to regularly update the cache with the status of the bridge resources
        let delay = 1 * Double(NSEC_PER_SEC)
        let time = DispatchTime.init(uptimeNanoseconds: UInt64(delay))
        DispatchQueue.main.asyncAfter(deadline: time) {
            self.enableLocalHeartbeat()
        }
    }
}
//
//
//// MARK: - BridgePushLinkViewControllerDelegate
extension AppDelegate: PHBridgePushLinkViewControllerDelegate {
    
    /// Delegate method for PHBridgePushLinkViewController which is invoked if the pushlinking was successfull
    func pushlinkSuccess() {
        // Push linking succeeded we are authenticated against the chosen bridge.
        
        // Remove pushlink view controller
        let vc = zHome.init(nibName: "zHome", bundle: nil)
        self.popover.contentViewController = vc
        
        // Start local heartbeat
        let delay = 1 * Double(NSEC_PER_SEC)
        let time = DispatchTime.init(uptimeNanoseconds: UInt64(delay))
        DispatchQueue.main.asyncAfter(deadline: time) {
            self.enableLocalHeartbeat()
        }
    }
    
    
    /// Delegate method for PHBridgePushLinkViewController which is invoked if the pushlinking was not successfull
    func pushlinkFailed(error: PHError) {
        // Remove pushlink view controller
        
        
        // Check which error occured
        if error.code == Int(PUSHLINK_NO_CONNECTION.rawValue) {
            noLocalConnection()
            
            // Start local heartbeat (to see when connection comes back)
            let delay = 1 * Double(NSEC_PER_SEC)
            let time = DispatchTime.init(uptimeNanoseconds: UInt64(delay))
            DispatchQueue.main.asyncAfter(deadline: time) {
                self.enableLocalHeartbeat()
            }
        } else {
            // Bridge button not pressed in time
            
                // Retry authentication
                self.doAuthentication()
            
                // Remove connecting loading message
                self.removeLoadingView()
                // Cancel authentication and disable local heartbeat unit started manually again
                self.disableLocalHeartbeat()
        }
    }
}


