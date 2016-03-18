//
//  DataChunk.swift
//  Keymochi
//
//  Created by Huai-Che Lu on 3/17/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import Foundation
import RealmSwift

class DataChunk: Object, CustomStringConvertible {
    
    convenience required init(emotion: Emotion) {
        self.init()
        self.emotion = emotion
    }
    
    var emotion: Emotion = .Neutral
    dynamic var symbolKeyEventSequence: SymbolKeyEventSequence?
    dynamic var backspaceKeyEventSequence: BackspaceKeyEventSequence?
    dynamic var accelerationDataSequence: MotionDataSequence?
    dynamic var gyroDataSequence: MotionDataSequence?
    
    override var description: String {
        get {
            
            let symbolKeyEventCount =
                (symbolKeyEventSequence != nil) ? symbolKeyEventSequence!.keyEvents.count : -1
            let accelerationDataPointCount =
                (accelerationDataSequence != nil) ? accelerationDataSequence!.motionDataPoints.count : -1
            let gyroDataPointCount =
                (gyroDataSequence != nil) ? gyroDataSequence!.motionDataPoints.count : -1
            
            return String(format: "[DataChunk]  %d symbols, %d acceleration dps, %d gyro dps",
                symbolKeyEventCount, accelerationDataPointCount, gyroDataPointCount)
        }
    }
}