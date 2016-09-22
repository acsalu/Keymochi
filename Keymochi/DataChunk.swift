//
//  DataChunk.swift
//  Keymochi
//
//  Created by Huai-Che Lu on 3/17/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import Foundation
import RealmSwift

class DataChunk: Object {
    
    fileprivate dynamic var emotionDescription: String?
    dynamic var symbolKeyEventSequence: SymbolKeyEventSequence?
    dynamic var backspaceKeyEventSequence: BackspaceKeyEventSequence?
    dynamic var accelerationDataSequence: MotionDataSequence?
    dynamic var gyroDataSequence: MotionDataSequence?
    dynamic var realmId: String = UUID().uuidString
    dynamic var createdAt: Date = Date()
    dynamic var parseId: String?
    dynamic var firebaseKey: String?
    dynamic var appVersion: String? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    override class func primaryKey() -> String? {
        return "realmId"
    }
    
    override var description: String {
        let symbolKeyEventCount =
            (symbolKeyEventSequence != nil) ? symbolKeyEventSequence!.keyEvents.count : -1
        let accelerationDataPointCount =
            (accelerationDataSequence != nil) ? accelerationDataSequence!.motionDataPoints.count : -1
        let gyroDataPointCount =
            (gyroDataSequence != nil) ? gyroDataSequence!.motionDataPoints.count : -1
        
        return String(format: "[DataChunk]  %d symbols, %d acceleration dps, %d gyro dps",
                      symbolKeyEventCount, accelerationDataPointCount, gyroDataPointCount)
    }
    
    var emotion: Emotion? {
        get {
            guard let emotionDescription = emotionDescription else {
                return nil
            }
            return Emotion(rawValue: emotionDescription)
        }
        
        set {
            emotionDescription = newValue?.rawValue
        }
    }
    
    var startTime: Double? {
        return keyEvents?.first?.downTime
    }
    
    var endTime: Double? {
        return keyEvents?.last?.upTime
    }
    
    var keyEvents: [KeyEvent]? {
        guard symbolKeyEventSequence != nil && backspaceKeyEventSequence != nil else {
            return nil
        }
        
        let symbolKeyEvents: [SymbolKeyEvent] =
            (symbolKeyEventSequence != nil) ? Array(symbolKeyEventSequence!.keyEvents) : []
        let backspaceKeyEvents: [BackspaceKeyEvent] =
            (backspaceKeyEventSequence != nil) ? Array(backspaceKeyEventSequence!.keyEvents) : []
        let keyEvents = ((symbolKeyEvents as [KeyEvent]) + (backspaceKeyEvents as [KeyEvent])).sorted { $0.downTime < $1.downTime }
        
        return keyEvents
    }
    
    var accelerationDataPoints: [MotionDataPoint]? {
        return accelerationDataSequence?.motionDataPoints.map { $0 }
    }
    
    var gyroDataPoints: [MotionDataPoint]? {
        return gyroDataSequence?.motionDataPoints.map { $0 }
    }
}

extension Array {
    var pair: [(Element, Element)]? {
        guard count > 1 else {
            return nil
        }
        return Array<(Element, Element)>(zip(self[0..<count-1], self[1..<count]))
    }
}

// MARK: - Stats
extension DataChunk {
    var symbolCounts: [String: Int]? {
        guard let symbols = symbolKeyEventSequence?.keyEvents.map({ $0.key }) else {
            return nil
        }
        
        var symbolCounts = [String: Int]()
        for symbol in symbols {
            if let symbol = symbol {
                if symbolCounts[symbol] == nil {
                    symbolCounts[symbol] = 1
                } else {
                    symbolCounts[symbol]! += 1
                }
            }
        }
        return symbolCounts
    }
    
    var totalNumberOfDeletions: Int? {
        return backspaceKeyEventSequence?.keyEvents
            .map { $0.numberOfDeletions }
            .reduce(0, +)
    }
    
    var interTapDistances: [Double]? {
        guard let keyEvents = keyEvents else {
            return nil
        }
        
        return keyEvents.pair?
            .map { return $0.1.downTime - $0.0.upTime }
    }
    
    var tapDurations: [Double]? {
        return keyEvents?.map { $0.duration }
    }
    
    var accelerationMagnitudes: [Double]? {
        return accelerationDataPoints?.map { $0.magnitude }
    }
    
    var gyroMagnitudes: [Double]? {
        return gyroDataPoints?.map { $0.magnitude }
    }
}
