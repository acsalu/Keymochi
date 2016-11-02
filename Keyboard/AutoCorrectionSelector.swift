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
			
			let stackView = UIStackView(arrangedSubviews: buttons)
			stackView.axis = .horizontal
			stackView.distribution = .fillEqually
			stackView.alignment = .fill
			stackView.spacing = 5
			stackView.translatesAutoresizingMaskIntoConstraints = false
			self.addSubview(stackView)
			
			let viewsDictionary = ["stackView":stackView]
			let stackView_H = NSLayoutConstraint.constraints(
				withVisualFormat: "H:|-20-[stackView]-20-|",  //horizontal constraint 20 points from left and right side
				options: NSLayoutFormatOptions(rawValue: 0),
				metrics: nil,
				views: viewsDictionary)
			self.addConstraints(stackView_H)
			
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
