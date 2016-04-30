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
    var realmConfig = Realm.Configuration()
    realmConfig.path = realmPath
    realmConfig.schemaVersion = 1
    realmConfig.migrationBlock = { (migration, oldSchemaVersion) in
      if oldSchemaVersion < 1 {
        migration.enumerate(DataChunk.className(), { (oldObject, newObject) in
          newObject!["appVersion"] = "0.2.0"
        })
      }
    }
    Realm.Configuration.defaultConfiguration = realmConfig
  }
  
  private let realmQueue = dispatch_queue_create("com.emomeapp.emome.suggestionQueue", DISPATCH_QUEUE_SERIAL)
  
  // MARK: - Key Events
  private var _symbolKeyEventSequence: SymbolKeyEventSequence = SymbolKeyEventSequence()
  private var _backspaceKeyEventSequence: BackspaceKeyEventSequence = BackspaceKeyEventSequence()
  
  func addKeyEvent(keyEvent: KeyEvent) {
    dispatch_async(realmQueue) { 
      if let symbolKeyEvent = keyEvent as? SymbolKeyEvent {
        self._symbolKeyEventSequence.keyEvents.append(symbolKeyEvent)
      } else if let backspaceKeyEvent = keyEvent as? BackspaceKeyEvent {
        self._backspaceKeyEventSequence.keyEvents.append(backspaceKeyEvent)
      }
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
      
        print("Dump current data in realm queue")
        print("(\(KeyType.Symbol)) \(_symbolKeyEventSequence.keyEvents.count) key events")
        print("(\(KeyType.Backspace)) \(_backspaceKeyEventSequence.keyEvents.count) key events")
        print("(\(SensorType.Acceleration)) \(_accelerationDataSequence.motionDataPoints.count) data points")
        print("(\(SensorType.Gyro)) \(_gyroDataSequence.motionDataPoints.count) data points")
      
        let dataChunck = DataChunk()
        dataChunck.symbolKeyEventSequence = _symbolKeyEventSequence
        dataChunck.backspaceKeyEventSequence = _backspaceKeyEventSequence
        dataChunck.accelerationDataSequence = _accelerationDataSequence
        dataChunck.gyroDataSequence = _gyroDataSequence
        
        addDataChunk(dataChunck)
      
        reset()
    }
  }
  
  func reset() {
    _symbolKeyEventSequence = SymbolKeyEventSequence()
    _backspaceKeyEventSequence = BackspaceKeyEventSequence()
    _accelerationDataSequence = MotionDataSequence.init(sensorType: .Acceleration)
    _gyroDataSequence = MotionDataSequence.init(sensorType: .Gyro)
  }
  
  var _realm: Realm?
  
  var realm: Realm {
    get {
      if let _realm = _realm {
        return _realm
      }
      return try! Realm.init(path: self.realmPath)
    }
  }
  
  func setRealm(realm: Realm) {
    _realm = realm
  }
  
}

extension DataManager {
  func getDataChunks() -> [DataChunk] {
    return Array(realm.objects(DataChunk))
  }
  
  func clearData() {
    realm.beginWrite()
    realm.deleteAll()
    try! realm.commitWrite()
  }
  
  func addDataChunk(dataChunck: DataChunk) {
      realm.beginWrite()
      realm.add(dataChunck)
      
      // Add Sequences
      if let symbolKeyEventSequence = dataChunck.symbolKeyEventSequence {
        realm.add(symbolKeyEventSequence)
        for keyEvent in symbolKeyEventSequence.keyEvents {
          realm.add(keyEvent)
        }
      }
      
      if let backspaceKeyEventSequence = dataChunck.backspaceKeyEventSequence {
        realm.add(backspaceKeyEventSequence)
        for keyEvent in backspaceKeyEventSequence.keyEvents {
          realm.add(keyEvent)
        }
      }
      
      if let accelerationDataSequence = dataChunck.accelerationDataSequence {
        realm.add(accelerationDataSequence)
        for dataPoint in accelerationDataSequence.motionDataPoints {
          realm.add(dataPoint)
        }
      }
      
      if let accelerationDataSequence = dataChunck.accelerationDataSequence {
        realm.add(accelerationDataSequence)
        for dataPoint in accelerationDataSequence.motionDataPoints {
          realm.add(dataPoint)
        }
      }
      
      if let gyroDataSequence = dataChunck.gyroDataSequence {
        realm.add(gyroDataSequence)
        for dataPoint in gyroDataSequence.motionDataPoints {
          realm.add(dataPoint)
        }
      }
    
      try! realm.commitWrite()
  }
  
  func updateDataChunk(dataChunk: DataChunk, withEmotion emotion: Emotion, andParseId parseId: String?) {
    realm.beginWrite()
    dataChunk.emotion = emotion
    dataChunk.parseId = parseId
    try! realm.commitWrite()
  }
  
  func updateDataChunk(dataChunk: DataChunk, withEmotion emotion: Emotion) {
    updateDataChunk(dataChunk, withEmotion: emotion, andParseId: nil)
  }
  
  
}