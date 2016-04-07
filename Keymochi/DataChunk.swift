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
      let symbolKeyEventCount =
        (symbolKeyEventSequence != nil) ? symbolKeyEventSequence!.keyEvents.count : -1
      let accelerationDataPointCount =
        (accelerationDataSequence != nil) ? accelerationDataSequence!.motionDataPoints.count : -1
      let gyroDataPointCount =
        (gyroDataSequence != nil) ? gyroDataSequence!.motionDataPoints.count : -1
      
      return String(format: "[DataChunk]  %d symbols, %d acceleration dps, %d gyro dps",
                    symbolKeyEventCount, accelerationDataPointCount, gyroDataPointCount)
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
    var keyEvents = (symbolKeyEvents as [KeyEvent]) + (backspaceKeyEvents as [KeyEvent])
    
    // Chronological order
    keyEvents.sortInPlace { $0.downTime < $1.downTime }
    
    return keyEvents
  }
  
  var accelerationDataPoints: [MotionDataPoint]? {
    return accelerationDataSequence?.motionDataPoints.map { $0 }
  }
  
  var gyroDataPoints: [MotionDataPoint]? {
    return gyroDataSequence?.motionDataPoints.map { $0 }
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
    return backspaceKeyEventSequence?.keyEvents.map { $0.numberOfDeletions }
      .reduce(0, combine: +)
  }
  
  var interTapDistances: [Double]? {
    guard let midTimes = (keyEvents?.map { ($0.downTime + $0.upTime) / 2 }) else {
      return nil
    }
    
    guard midTimes.count > 1 else {
      return []
    }
    
    var interTapDistances = [Double]()
    for index in 0..<midTimes.count - 1 {
      interTapDistances.append(midTimes[index + 1] - midTimes[index])
    }
    
    return interTapDistances
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