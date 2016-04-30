//
//  KeymochiKeyboardViewController.swift
//  Keymochi
//
//  Created by Huai-Che Lu on 4/13/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import UIKit
import CoreMotion

class KeymochiKeyboardViewController: KeyboardViewController {
  
  var motionManager: CMMotionManager!
  
  var backspaceKeyEvent: BackspaceKeyEvent?
  var symbolKeyEventMap: [String: SymbolKeyEvent]!
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    symbolKeyEventMap = [String: SymbolKeyEvent]()
    
    motionManager = CMMotionManager()
    let motionUpdateInterval: NSTimeInterval = 0.1
    motionManager.deviceMotionUpdateInterval = motionUpdateInterval
    motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()) { (deviceMotioin, error) in
      guard error == nil else {
        debugPrint(error)
        return
      }
      guard let deviceMotioin = deviceMotioin else {
        return
      }
      
      let accelerationDataPoint = MotionDataPoint(acceleration: deviceMotioin.userAcceleration, atTime: deviceMotioin.timestamp)
      let gyroDataPoint = MotionDataPoint(rotationRate: deviceMotioin.rotationRate, atTime: deviceMotioin.timestamp)
      DataManager.sharedInatance.addMotionDataPoint(accelerationDataPoint, ofSensorType: .Acceleration)
      DataManager.sharedInatance.addMotionDataPoint(gyroDataPoint, ofSensorType: .Gyro)
    }
  }
  
  override func viewDidDisappear(animated: Bool) {
    motionManager.stopDeviceMotionUpdates()
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
