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
    
    
    let directoryURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.groupIdentifier)
    let realmPath: String
    
    init() {
        realmPath = (directoryURL?.appendingPathComponent("db.realm").path)!
        var realmConfig = Realm.Configuration()
        realmConfig.fileURL = URL(fileURLWithPath: realmPath)
        realmConfig.schemaVersion = 2
        realmConfig.migrationBlock = { (migration, oldSchemaVersion) in
            if oldSchemaVersion < 1 {
                migration.enumerateObjects(ofType: DataChunk.className(), { (oldObject, newObject) in
                    newObject!["appVersion"] = "0.2.0"
                })
            }
            if oldSchemaVersion < 2 {
                migration.enumerateObjects(ofType: DataChunk.className(), { (oldObject, newObject) in
                    guard let emotionDescription = oldObject!["emotionDescription"] else {
                        return
                    }
                    
                    if emotionDescription as! String == Emotion.Neutral.description {
                        newObject!["emotionDescription"] = nil
                    }
                })
            }
            
        }
        Realm.Configuration.defaultConfiguration = realmConfig
    }
    
    fileprivate let realmQueue = DispatchQueue(label: "com.emomeapp.emome.suggestionQueue", attributes: [])
    
    // MARK: - Key Events
    fileprivate var _symbolKeyEventSequence: SymbolKeyEventSequence = SymbolKeyEventSequence()
    fileprivate var _backspaceKeyEventSequence: BackspaceKeyEventSequence = BackspaceKeyEventSequence()
    
    func addKeyEvent(_ keyEvent: KeyEvent) {
        realmQueue.async {
            if let symbolKeyEvent = keyEvent as? SymbolKeyEvent {
                self._symbolKeyEventSequence.keyEvents.append(symbolKeyEvent)
            } else if let backspaceKeyEvent = keyEvent as? BackspaceKeyEvent {
                self._backspaceKeyEventSequence.keyEvents.append(backspaceKeyEvent)
            }
        }
    }
    
    // MARK: - Motion Data
    fileprivate var _accelerationDataSequence: MotionDataSequence = MotionDataSequence.init(sensorType: .acceleration)
    fileprivate var _gyroDataSequence: MotionDataSequence = MotionDataSequence.init(sensorType: .gyro)
    
    func addMotionDataPoint(_ dataPoint: MotionDataPoint, ofSensorType sensorType: SensorType) {
        
        switch sensorType {
        case .acceleration: _accelerationDataSequence.motionDataPoints.append(dataPoint)
        case .gyro: _gyroDataSequence.motionDataPoints.append(dataPoint)
        }
    }
    
    func dumpCurrentData() {
        let totalKeyCount =
            _symbolKeyEventSequence.keyEvents.count + _backspaceKeyEventSequence.keyEvents.count
        
        // Data without legit intertap distance shall not pass.
        if totalKeyCount > 2  {
            print("Dump current data in realm queue")
            print("(\(KeyType.symbol)) \(_symbolKeyEventSequence.keyEvents.count) key events")
            print("(\(KeyType.backspace)) \(_backspaceKeyEventSequence.keyEvents.count) key events")
            print("(\(SensorType.acceleration)) \(_accelerationDataSequence.motionDataPoints.count) data points")
            print("(\(SensorType.gyro)) \(_gyroDataSequence.motionDataPoints.count) data points")
            
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
        _accelerationDataSequence = MotionDataSequence.init(sensorType: .acceleration)
        _gyroDataSequence = MotionDataSequence.init(sensorType: .gyro)
    }
    
    var _realm: Realm?
    
    var realm: Realm {
        get {
            if let _realm = _realm {
                return _realm
            }
            return try! Realm(fileURL: URL(fileURLWithPath: self.realmPath))
        }
    }
    
    func setRealm(_ realm: Realm) {
        _realm = realm
    }
    
}

extension DataManager {
    func getDataChunks() -> [DataChunk] {
        return Array(realm.allObjects(ofType: DataChunk.self))
    }
    
    func clearData() {
        realm.beginWrite()
        realm.deleteAllObjects()
        try! realm.commitWrite()
    }
    
    func addDataChunk(_ dataChunck: DataChunk) {
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
    
    func updateDataChunk(_ dataChunk: DataChunk, withEmotion emotion: Emotion, andParseId parseId: String?) {
        realm.beginWrite()
        dataChunk.emotion = emotion
        dataChunk.parseId = parseId
        try! realm.commitWrite()
    }
    
    func updateDataChunk(_ dataChunk: DataChunk, withEmotion emotion: Emotion) {
        updateDataChunk(dataChunk, withEmotion: emotion, andParseId: nil)
    }
    
    
}
