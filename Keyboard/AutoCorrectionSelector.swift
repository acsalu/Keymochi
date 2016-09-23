//
//  AutoCorrectionSelector.swift
//  Keymochi
//
//  Created by HsiaoChing Lin on 9/22/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import Foundation
import UIKit

protocol AutoCorrectionSelectorDelegate {
	func autoCorrectionSelector(_:AutoCorrectionSelector, correctWithWord word: String)
}

class AutoCorrectionSelector: ExtraView {
	
	var buttons = [UIButton]()
	var delegate: AutoCorrectionSelectorDelegate?
	
	required init(globalColors: GlobalColors.Type?, darkMode: Bool, solidColorMode: Bool) {
		super.init(globalColors: globalColors, darkMode: darkMode, solidColorMode: solidColorMode)
		
		for i in 0 ..< 3 {
			let button = UIButton(frame: CGRect(x: 100 * i, y:-5, width: 100, height: 50))
			self.buttons.insert(button, at: i)
			self.addSubview(self.buttons[i])
			self.buttons[i].addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)
		}
	}
	
	func buttonAction(sender: UIButton) {
		delegate?.autoCorrectionSelector(self, correctWithWord: sender.title(for: .normal)! + " ")
	}
	
	func updateButtonArray(words: [String]) {
		for i in 0 ..< words.count {
			self.buttons[i].setTitle(words[i], for: .normal)
		}
		for i in words.count ..< 3 {
			self.buttons[i].setTitle("", for: .normal)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
