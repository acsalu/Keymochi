//
//  KeyEvent.swift
//  Keymochi
//
//  Created by Huai-Che Lu on 3/2/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import Foundation
import RealmSwift

enum KeyType: CustomStringConvertible, CustomDebugStringConvertible {
  case Symbol, Backspace
  
  var description: String {
    switch (self) {
    case .Symbol: return "Symbol"
    case .Backspace: return "Backspace"
    }
  }
  
  var debugDescription: String {
    return description
  }
}

class SymbolKeyEventSequence: Object {
  let keyEvents = List<SymbolKeyEvent>()
}

class BackspaceKeyEventSequence: Object {
  let keyEvents = List<BackspaceKeyEvent>()
}

class SymbolKeyEvent: KeyEvent {
  dynamic var key: String?
}

class BackspaceKeyEvent: KeyEvent {
  dynamic var numberOfDeletions: Int = 0
}

class KeyEvent: Object {
  dynamic var downTime: Double = 0.0
  dynamic var upTime: Double = 0.0
  
  var duration: Double {
    return upTime - downTime
  }
}