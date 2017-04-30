//
//  zAmbiLightController.swift
//  AmbiMac
//
//  Created by Floris-Jan Willemsen on 29-04-17.
//  Copyright © 2017 Floris-Jan Willemsen. All rights reserved.
//

import Foundation

class zAmbiLightController {
    
    let precision :Int = 50              //The higher the number, the lower the precision
    let responsiveness :Double = 3      //The lower the number, the higher the responsivness at the cost of processing power
    var timer = Timer()
    var lights :[PHLight] = []
    let bridgeSendAPI = PHBridgeSendAPI()
    
    init() {
        scheduledTimerWithTimeInterval()
    }
    
    func addLight(light :PHLight) {
        lights.append(light)
    }
    
    func removeLight(rlight :PHLight) {
        var counter = 0
        for light in lights {
            if light.identifier == rlight.identifier {
                lights.remove(at: counter)
                return
            }
            counter = counter + 1
        }
    }
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function **Countdown** with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: responsiveness, target: self, selector: #selector(self.setColor), userInfo: nil, repeats: true)
    }
    
    
    @objc func setColor() {
        
        var displayCount: UInt32 = 0;
        var result = CGGetActiveDisplayList(0, nil, &displayCount)
        if (result != CGError.success) {
            print("error: \(result)")
            return
        }
        let allocated = Int(displayCount)
        let activeDisplays = UnsafeMutablePointer<CGDirectDisplayID>.allocate(capacity: allocated)
        result = CGGetActiveDisplayList(displayCount, activeDisplays, &displayCount)
        
        if (result != CGError.success) {
            print("error: \(result)")
            return
        }
        
//        For Multiple Displays
        
//        for i in 1...displayCount {
//            let screenShot:CGImage = CGDisplayCreateImage(activeDisplays[Int(i-1)])!
//            let bitmapRep = NSBitmapImageRep(cgImage: screenShot)
//            color = averageImageColor(image: bitmapRep)     //Average color
//            print(color)
//        }
        
        
//        For a Single Display
        
        let screenShot:CGImage = CGDisplayCreateImage(activeDisplays[Int(0)])!
        let bitmapRep = NSBitmapImageRep(cgImage: screenShot)
        let color = averageImageColor(image: bitmapRep)     //Average color
        let brightness :Int = Int((color.red + color.green + color.blue) / 3)
        print(brightness)
        
        for light in lights {
            light.lightState = PHLightState().createFromRGB(rgb: color, brightness: brightness, light: light)
            
            // Send lightstate to light
            bridgeSendAPI.updateLightState(forId: light.identifier, with: light.lightState, completionHandler: { (errors: Optional<Array<Any>>) -> () in
                
                if errors != nil {
                    let message = String(format: NSLocalizedString("Errors %@", comment: ""), errors!)
                    NSLog("Response: \(message)")
                }
            } as PHBridgeSendErrorArrayCompletionHandler )
        }
    }
    
    func averageImageColor(image :NSBitmapImageRep) -> RGBColor {
        
        var x :Int = 0
        var y :Int = 0
        var pixel :NSColor
        
        var red :CGFloat = 0
        var green :CGFloat = 0
        var blue :CGFloat = 0
        
        while (y < Int(image.size.height)) {
            x = 0
            
            while (x < Int(image.size.width)) {
                pixel = image.colorAt(x: x, y: y)!
                
                red = red + pixel.redComponent
                green = green + pixel.greenComponent
                blue = blue + pixel.blueComponent
                
                x = x + precision
            }
            
            y = y + precision
        }
        
        let count :CGFloat = CGFloat((x / precision) * (y / precision))
        return RGBColor.init(red: UInt16(red / count * 254), green: UInt16(green / count * 254), blue: UInt16(blue / count * 254))
    }
}

extension PHLightState {
    func createFromRGB(rgb :RGBColor, brightness: Int, light: PHLight) -> PHLightState {
        let color = NSColor.init(red: CGFloat(rgb.red), green: CGFloat(rgb.green), blue: CGFloat(rgb.blue), alpha: 1)
        var xy = PHUtilities.calculateXY(color, forModel: "")
        
        xy.x = CGFloat(Double(String(format: "%.2f", xy.x))!)
        xy.y = CGFloat(Double(String(format: "%.2f", xy.y))!)
        
        let lightState = PHLightState()
        lightState.brightness = brightness as NSNumber
        lightState.saturation = 254
        lightState.on = true
        lightState.x = xy.x as NSNumber
        lightState.y = xy.y as NSNumber
        
        return lightState
    }
}
