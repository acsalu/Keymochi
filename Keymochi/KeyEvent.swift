//
//  KeyEvent.swift
//  Keymochi
//
//  Created by Huai-Che Lu on 3/2/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import Foundation
import RealmSwift

class KeyEvent: Object {
    dynamic var key: String?
    dynamic var downTime: Double = 0.0
    dynamic var upTime: Double = 0.0
}