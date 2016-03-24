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
  
  var emotion: Emotion = .Neutral
  dynamic var symbolKeyEventSequence: SymbolKeyEventSequence?
  dynamic var backspaceKeyEventSequence: BackspaceKeyEventSequence?
  dynamic var accelerationDataSequence: MotionDataSequence?
  dynamic var gyroDataSequence: MotionDataSequence?
  
  convenience required init(emotion: Emotion) {
    self.init()
    self.emotion = emotion
  }
  
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
  
  var startTime: Double? {
    get {
      guard let first = self.keyEvents.first else {
        return nil
      }
      return first.downTime
    }
  }
  
  var endTime: Double? {
    get {
      guard let last = self.keyEvents.last else {
        return nil
      }
      return last.upTime
    }
  }
  
  var keyEvents: [KeyEvent] {
    get {
      let symbolKeyEvents: [SymbolKeyEvent] =
        (symbolKeyEventSequence != nil) ? Array(symbolKeyEventSequence!.keyEvents) : []
      let backspaceKeyEvents: [BackspaceKeyEvent] =
        (backspaceKeyEventSequence != nil) ? Array(backspaceKeyEventSequence!.keyEvents) : []
      
      var keyEvents = (symbolKeyEvents as [KeyEvent]) + (backspaceKeyEvents as [KeyEvent])
      
      // Chronological order
      keyEvents.sortInPlace {
        return $0.downTime < $1.downTime
      }
      
      return keyEvents
    }
  }
  
  var accelerationDataPoints: [MotionDataPoint] {
    get {
      return (self.accelerationDataSequence?.motionDataPoints.map { $0 })!
    }
  }
  
  var gyroDataPoints: [MotionDataPoint] {
    get {
      return (self.gyroDataSequence?.motionDataPoints.map { $0 })!
    }
  }
}