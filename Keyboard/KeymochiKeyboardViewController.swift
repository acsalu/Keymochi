//
//  KeymochiKeyboardViewController.swift
//  Keymochi
//
//  Created by Huai-Che Lu on 4/13/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import UIKit
import MotionKit

class KeymochiKeyboardViewController: KeyboardViewController {
  
  var motionKit: MotionKit!
  let motionUpdateInterval = 0.25
  
  var backspaceKeyEvent: BackspaceKeyEvent?
  var symbolKeyEventMap: [String: SymbolKeyEvent]!
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    symbolKeyEventMap = [String: SymbolKeyEvent]()
    motionKit = MotionKit()
    
    motionKit.getAccelerationFromDeviceMotion(motionUpdateInterval) { (x, y, z) -> () in
      let dataPoint = MotionDataPoint()
      dataPoint.x = x
      dataPoint.y = y
      dataPoint.z = z
      dataPoint.time = CACurrentMediaTime()
      DataManager.sharedInatance.addMotionDataPoint(dataPoint, ofSensorType: .Acceleration)
    }
    
    motionKit.getGyroValues(motionUpdateInterval) { (x, y, z) -> () in
      let dataPoint = MotionDataPoint()
      dataPoint.x = x
      dataPoint.y = y
      dataPoint.z = z
      dataPoint.time = CACurrentMediaTime()
      DataManager.sharedInatance.addMotionDataPoint(dataPoint, ofSensorType: .Gyro)
    }
  }
  
  override func viewDidDisappear(animated: Bool) {
    motionKit.stopDeviceMotionUpdates()
    motionKit.stopGyroUpdates()
    DataManager.sharedInatance.dumpCurrentData()
    super.viewDidDisappear(animated)
  }
  
  override func symbolKeyUp(sender: KeyboardKey) {
    guard let key = self.layout?.keyForView(sender)?.outputForCase(self.shiftState.uppercase()) else {
      return
    }
    
    guard let symbolKeyEvent = symbolKeyEventMap[key] else {
      return
    }
    
    symbolKeyEvent.upTime = CACurrentMediaTime()
    DataManager.sharedInatance.addKeyEvent(symbolKeyEvent)
  }
  
  override func symbolKeyDown(sender: KeyboardKey) {
    guard let key = self.layout?.keyForView(sender)?.outputForCase(self.shiftState.uppercase()) else {
      return
    }
    
    let symbolKeyEvent = SymbolKeyEvent()
    symbolKeyEvent.downTime = CACurrentMediaTime()
    symbolKeyEvent.key = key
    symbolKeyEventMap[key] = symbolKeyEvent
  }
  
  override func backspaceDown(sender: KeyboardKey) {
    let keyEvent = BackspaceKeyEvent()
    keyEvent.downTime = CACurrentMediaTime()
    backspaceKeyEvent = keyEvent
    
    super.backspaceDown(sender)
  }
  
  override func backspaceUp(sender: KeyboardKey) {
    if let backspaceKeyEvent = backspaceKeyEvent {
      backspaceKeyEvent.upTime = CACurrentMediaTime()
      backspaceKeyEvent.numberOfDeletions = numberOfDeletions
      DataManager.sharedInatance.addKeyEvent(backspaceKeyEvent)
      self.backspaceKeyEvent = nil
    }
    
    super.backspaceUp(sender)
  }
}
