//
//  Motion.swift
//  Keymochi
//
//  Created by Huai-Che Lu on 3/16/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import Foundation
import RealmSwift
import CoreMotion

enum SensorType: CustomStringConvertible, CustomDebugStringConvertible {
  case Acceleration, Gyro
  
  var description: String {
    switch (self) {
    case .Acceleration: return "Acceleration"
    case .Gyro: return "Gyro"
    }
  }
  
  var debugDescription: String {
    return description
  }
}

class MotionDataCollection: Object {
  dynamic var accelerationDataSequence: MotionDataSequence?
  dynamic var gyroDataSequence: MotionDataSequence?
}

class MotionDataSequence: Object {
  
  convenience required init(sensorType: SensorType) {
    self.init()
    self.sensorType = sensorType
  }
  
  var sensorType: SensorType = .Acceleration
  let motionDataPoints = List<MotionDataPoint>()
  
  var timestamps: [String] {
    
    guard !motionDataPoints.isEmpty else {
      return []
    }
    
    let first = motionDataPoints[0].time
    
    return motionDataPoints.map { String(format: "%.5f", $0.time - first) }
  }
}

class MotionDataPoint: Object {
  dynamic var x: Double = 0.0
  dynamic var y: Double = 0.0
  dynamic var z: Double = 0.0
  dynamic var time: Double = 0.0
  
  convenience init(acceleration: CMAcceleration, atTime timestamp: NSTimeInterval) {
    self.init()
    x = acceleration.x
    y = acceleration.y
    z = acceleration.z
    time = timestamp
  }
  
  convenience init(rotationRate: CMRotationRate, atTime timestamp: NSTimeInterval) {
    self.init()
    x = rotationRate.x
    y = rotationRate.y
    z = rotationRate.z
    time = timestamp
  }
  
  var magnitude: Double {
    return sqrt(x * x + y * y + z * z)
  }
  
  override var description: String {
    return String(format: "%.3f (%.3f, %.3f, %.3f)", magnitude, x, y, z)
  }
}

