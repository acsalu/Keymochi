//
//  Emotion.swift
//  Keymochi
//
//  Created by Huai-Che Lu on 3/17/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import Foundation

enum Emotion: String, CustomStringConvertible {
  case Neutral = "Neutral"
  case Happy = "Happy"
  case Sad = "Sad"
  
  static let all: [Emotion] = [.Happy, .Neutral, .Sad]
  
  var description: String {
    return rawValue
  }
}