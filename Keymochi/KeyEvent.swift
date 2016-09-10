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
    case symbol, backspace
    
    var description: String {
        switch (self) {
        case .symbol: return "Symbol"
        case .backspace: return "Backspace"
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
    
    override var description: String {
        return key ?? ""
    }
}

class BackspaceKeyEvent: KeyEvent {
    dynamic var numberOfDeletions: Int = 0
    override var description: String {
        return "← \(numberOfDeletions)"
    }
}

class KeyEvent: Object {
    dynamic var downTime: Double = 0.0
    dynamic var upTime: Double = 0.0
    
    var duration: Double {
        return (upTime - downTime) * 1000
    }
    
    var timestamp: String {
        return String(format: "%.0f (%.2f - %.2f)", duration, downTime, upTime)
    }
}
