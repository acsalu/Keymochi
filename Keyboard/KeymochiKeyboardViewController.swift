//
//  KeymochiKeyboardViewController.swift
//  Keymochi
//
//  Created by Huai-Che Lu on 4/13/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import UIKit
import CoreMotion

class KeymochiKeyboardViewController: KeyboardViewController {
    
    
    var motionManager: CMMotionManager!
    
    var backspaceKeyEvent: BackspaceKeyEvent?
    var symbolKeyEventMap: [String: SymbolKeyEvent]!
    
    var currentWord: String = ""
	var lastWord: String = ""
	
	var autoCorrectionSelector: AutoCorrectionSelector {
		return self.bannerView as! AutoCorrectionSelector
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        symbolKeyEventMap = [String: SymbolKeyEvent]()
        
        // Make sure the container is empty.
        DataManager.sharedInatance.reset()
        
        motionManager = CMMotionManager()
        let motionUpdateInterval: TimeInterval = 0.1
        motionManager.deviceMotionUpdateInterval = motionUpdateInterval
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (deviceMotioin, error) in
            guard error == nil else {
                debugPrint(error)
                return
            }
            guard let deviceMotioin = deviceMotioin else {
                return
            }
            
            let accelerationDataPoint = MotionDataPoint(acceleration: deviceMotioin.userAcceleration, atTime: deviceMotioin.timestamp)
            let gyroDataPoint = MotionDataPoint(rotationRate: deviceMotioin.rotationRate, atTime: deviceMotioin.timestamp)
            DataManager.sharedInatance.addMotionDataPoint(accelerationDataPoint, ofSensorType: .acceleration)
            DataManager.sharedInatance.addMotionDataPoint(gyroDataPoint, ofSensorType: .gyro)
        }
		
		self.autoCorrectionSelector.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        motionManager.stopDeviceMotionUpdates()
        DataManager.sharedInatance.dumpCurrentData()
        super.viewDidDisappear(animated)
    }
    
    override func symbolKeyUp(_ sender: KeyboardKey) {
        guard let key = self.layout?.keyForView(key: sender)?.outputForCase(self.shiftState.uppercase()) else {
            return
        }
        
        guard let symbolKeyEvent = symbolKeyEventMap[key] else {
            return
        }
        
        symbolKeyEvent.upTime = CACurrentMediaTime()
        DataManager.sharedInatance.addKeyEvent(symbolKeyEvent)
		
        if key == " " {
			let words : [String] = (textDocumentProxy.documentContextBeforeInput?.components(separatedBy: " "))!
			if lastWord == "" {
				lastWord = words.last!
			} else if lastWord != words.last! {
				lastWord = words.last!
				if let guesses = getSuggestedWords()?.gussess {
					replaceWord(replacement: guesses[0])
				}
			}
			currentWord = ""
			(self.bannerView as! AutoCorrectionSelector).updateButtonArray(words: [])
			
        } else {
			currentWord += key
			if let completions = getSuggestedWords()?.completions {
				var partialGuesses: [String]
				if completions.count < 3 {
					partialGuesses = completions
				} else {
					partialGuesses = Array(completions[0...2])
				}
				self.autoCorrectionSelector.updateButtonArray(words: partialGuesses)
			}
		}
    }
	
	func getSuggestedWords() -> (completions: [String], gussess: [String])? {
		let textChecker = UITextChecker()
		let range = NSRange(location: 0, length: currentWord.characters.count)
		let misspelledRange = textChecker.rangeOfMisspelledWord(
			in: currentWord, range: range, startingAt: 0, wrap: false, language: "en_US")
		if misspelledRange.location != NSNotFound {
			let completions: [String] = textChecker.completions(forPartialWordRange: range, in: currentWord, language: "en_US")!
			let guesses: [String] = textChecker.guesses(forWordRange: range, in: currentWord, language: "en_US")!
			return (completions, guesses)
		}
		return nil
	}
	
	func replaceWord(replacement: String){
		for _ in 0..<currentWord.characters.count {
			textDocumentProxy.deleteBackward()
		}
		textDocumentProxy.insertText(replacement)
	}
	
    override func symbolKeyDown(_ sender: KeyboardKey) {
        guard let key = self.layout?.keyForView(key: sender)?.outputForCase(self.shiftState.uppercase()) else {
            return
        }
        
        let symbolKeyEvent = SymbolKeyEvent()
        symbolKeyEvent.downTime = CACurrentMediaTime()
        symbolKeyEvent.key = key
        symbolKeyEventMap[key] = symbolKeyEvent
    }
    
    override func backspaceDown(_ sender: KeyboardKey) {
        let keyEvent = BackspaceKeyEvent()
        keyEvent.downTime = CACurrentMediaTime()
        backspaceKeyEvent = keyEvent
		if currentWord.characters.count > 0 {
			currentWord.remove(at: currentWord.index(before: currentWord.endIndex))
		}
		
        super.backspaceDown(sender)
    }
    
    override func backspaceUp(_ sender: KeyboardKey) {
        if let backspaceKeyEvent = backspaceKeyEvent {
            backspaceKeyEvent.upTime = CACurrentMediaTime()
            backspaceKeyEvent.numberOfDeletions = numberOfDeletions
            DataManager.sharedInatance.addKeyEvent(backspaceKeyEvent)
            self.backspaceKeyEvent = nil
        }
        
        super.backspaceUp(sender)
    }
	
	override func createBanner() -> ExtraView? {
		return AutoCorrectionSelector(globalColors: type(of: self).globalColors, darkMode: false, solidColorMode: self.solidColorMode())
	}
}

// MARK: - AutoCorrectionSelectorDelegate Methods
extension KeymochiKeyboardViewController: AutoCorrectionSelectorDelegate {
	func autoCorrectionSelector(_: AutoCorrectionSelector, correctWithWord word: String) {
		replaceWord(replacement: word)
		currentWord = ""
		self.autoCorrectionSelector.updateButtonArray(words: [])
	}
}
