//
//  ToggleButton.swift
//  bVNC
//
//  Created by iordan iordanov on 2020-03-19.
//  Copyright © 2020 iordan iordanov. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox

class ToggleButton: UIButton {
    var originalBackground: UIColor?
    var toSend: Int32?
    var down: Bool = false
    var stateKeeper: StateKeeper?
    
    init (frame: CGRect, title: String, background: UIColor, stateKeeper: StateKeeper, toSend: Int32, toggle: Bool) {
        super.init(frame: frame)
        self.stateKeeper = stateKeeper
        self.setTitle(title, for: [])
        self.originalBackground = background
        self.backgroundColor = background
        if toggle && toSend >= 0 {
            self.addTarget(self, action: #selector(self.sendToggleText), for: .touchDown)
        } else if (toSend >= 0) {
            self.addTarget(self, action: #selector(self.sendText), for: .touchDown)
        }
        self.toSend = toSend
    }
    
    @objc func sendToggleText() {
        AudioServicesPlaySystemSound(1100);
        down = !down
        print("Toggled my xksysym: \(toSend!), down: \(down)")
        sendUniDirectionalKeyEventWithKeySym(self.stateKeeper!.cl[self.stateKeeper!.currInst]!, toSend!, down)
        self.stateKeeper?.rescheduleScreenUpdateRequest(timeInterval: 0.5, fullScreenUpdate: false, recurring: false)
        UserInterface {
            if self.down {
                self.backgroundColor = self.originalBackground?.withAlphaComponent(0.75)
            } else {
                self.backgroundColor = self.originalBackground?.withAlphaComponent(0.5)
            }
            self.setNeedsDisplay()
        }
    }

    @objc func sendText() {
        AudioServicesPlaySystemSound(1100);
        //print("Sending my xksysym: \(toSend!), up and then down.")
        sendKeyEventWithKeySym(self.stateKeeper!.cl[self.stateKeeper!.currInst]!, toSend!)
        self.stateKeeper?.toggleModifiersIfDown()
        self.stateKeeper?.rescheduleScreenUpdateRequest(timeInterval: 0.5, fullScreenUpdate: false, recurring: false)
    }

    @objc func sendUpIfToggled() {
        if down {
            sendToggleText()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
