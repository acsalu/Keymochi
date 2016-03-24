//
//  DataManager.swift
//  Keymochi
//
//  Created by Huai-Che Lu on 3/16/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import Foundation
import RealmSwift

class DataManager {
  
  static let sharedInatance = DataManager()
  
  let directoryURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(Constants.groupIdentifier)
  let realmPath: String
  
  init() {
    realmPath = (directoryURL?.URLByAppendingPathComponent("db.realm").path)!
  }
  
  private let realmQueue = dispatch_queue_create("com.emomeapp.emome.suggestionQueue", DISPATCH_QUEUE_SERIAL)
  
  // MARK: - Key Events
  private var _symbolKeyEventSequence: SymbolKeyEventSequence = SymbolKeyEventSequence()
  private var _backspaceKeyEventSequence: BackspaceKeyEventSequence = BackspaceKeyEventSequence()
  
  func addKeyEvent(event: KeyEvent, ofKeyType keyType: KeyType) {
    
    switch keyType {
    case .Symbol: _symbolKeyEventSequence.keyEvents.append(event as! SymbolKeyEvent)
    case .Backspace: _backspaceKeyEventSequence.keyEvents.append(event as! BackspaceKeyEvent)
    }
  }
  
  // MARK: - Motion Data
  private var _accelerationDataSequence: MotionDataSequence = MotionDataSequence.init(sensorType: .Acceleration)
  private var _gyroDataSequence: MotionDataSequence = MotionDataSequence.init(sensorType: .Gyro)
  
  func addMotionDataPoint(dataPoint: MotionDataPoint, ofSensorType sensorType: SensorType) {
    
    switch sensorType {
    case .Acceleration: _accelerationDataSequence.motionDataPoints.append(dataPoint)
    case .Gyro: _gyroDataSequence.motionDataPoints.append(dataPoint)
    }
  }
  
  func dumpCurrentData() {
    
    if _symbolKeyEventSequence.keyEvents.count > 0 {
      
      dispatch_async(realmQueue) {
        print("Dump current data in realm queue")
        print("(\(KeyType.Symbol)) \(self._symbolKeyEventSequence.keyEvents.count) key events")
        print("(\(KeyType.Backspace)) \(self._backspaceKeyEventSequence.keyEvents.count) key events")
        print("(\(SensorType.Acceleration)) \(self._accelerationDataSequence.motionDataPoints.count) data points")
        print("(\(SensorType.Gyro)) \(self._gyroDataSequence.motionDataPoints.count) data points")
        
        let realm = try! Realm.init(path: self.realmPath)
        realm.beginWrite()
        
        // Add KeyEvents
        for keyEvent in self._symbolKeyEventSequence.keyEvents {
          realm.add(keyEvent)
        }
        
        for keyEvent in self._backspaceKeyEventSequence.keyEvents {
          realm.add(keyEvent)
        }
        
        // Add MotionDataPoints
        for dataPoint in self._accelerationDataSequence.motionDataPoints {
          realm.add(dataPoint)
        }
        
        for dataPoint in self._accelerationDataSequence.motionDataPoints {
          realm.add(dataPoint)
        }
        
        // Add Sequences
        realm.add(self._symbolKeyEventSequence)
        realm.add(self._backspaceKeyEventSequence)
        realm.add(self._accelerationDataSequence)
        realm.add(self._gyroDataSequence)
        
        // Add event
        let dataChunck = DataChunk()
        dataChunck.symbolKeyEventSequence = self._symbolKeyEventSequence
        dataChunck.backspaceKeyEventSequence = self._backspaceKeyEventSequence
        dataChunck.accelerationDataSequence = self._accelerationDataSequence
        dataChunck.gyroDataSequence = self._gyroDataSequence
        realm.add(dataChunck)
        
        try! realm.commitWrite()
        
        self._symbolKeyEventSequence = SymbolKeyEventSequence()
        self._backspaceKeyEventSequence = BackspaceKeyEventSequence()
        self._accelerationDataSequence = MotionDataSequence.init(sensorType: .Acceleration)
        self._gyroDataSequence = MotionDataSequence.init(sensorType: .Gyro)
      }
    }
  }
}