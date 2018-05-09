//
//  BlinkingView.swift
//  test
//
//  Created by Damien BALLENGHIEN on 23/06/2016.
//  Copyright © 2016 Damien BALLENGHIEN. All rights reserved.
//

import UIKit

private var blinkStatus : Bool = false
private var timer : Timer!
private var repeatsCounter : Int = -1

extension UIView{
    
    func startBlinking(duration : Float){
//        if (timer != nil){
//            timer.invalidate()
//        }
        timer = Timer.scheduledTimer(timeInterval: (TimeInterval)(duration),
                                                       target: self,
                                                       selector: #selector(blink),
                                                       userInfo: nil,
                                                       repeats: true)
    }

    func startBlinking(duration : Float, repeats : Int){
        if (timer != nil){
            timer.invalidate()
        }
        repeatsCounter = repeats
        timer = Timer.scheduledTimer(timeInterval: (TimeInterval)(duration),
                                                       target: self,
                                                       selector: #selector(blink),
                                                       userInfo: nil,
                                                       repeats: true)
    }
    
    @objc private func blink(){
        UIView.animate(withDuration: 0.6, animations: {
            if blinkStatus == false {
                self.alpha = 0
                blinkStatus = true
            } else {
                self.alpha = 1
                blinkStatus = false;
            }
        }) { (done) in
            if repeatsCounter != -1 {
                if repeatsCounter == 0 {
                    self.stopBlinking()
                }
                repeatsCounter -= 1
            }
        }
    }
    
    func stopBlinking(){
        if (self.alpha == 0 || self.alpha == 1){
            UIView.animate(withDuration: 0.6) { () -> Void in
                self.alpha = 1
            }
            if (timer != nil){
                timer.invalidate()
            }
        }
    }
}
