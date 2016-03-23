//
//  Emotion.swift
//  Keymochi
//
//  Created by Huai-Che Lu on 3/17/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import Foundation

enum Emotion: CustomStringConvertible {
    case Neutral, Happy, Sad
    
    var description: String {
        get {
            switch self {
            case .Neutral: return "Neutral"
            case .Happy: return "Happy"
            case .Sad: return "Sad"
            }
        }
    }
}