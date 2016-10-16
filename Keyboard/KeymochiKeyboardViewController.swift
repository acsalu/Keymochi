//
//  KeymochiKeyboardViewController.swift
//  Keymochi
//
//  Created by Huai-Che Lu on 4/13/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import UIKit
import CoreMotion

import PAM

class KeymochiKeyboardViewController: KeyboardViewController {
    
    var motionManager: CMMotionManager!
    
    var backspaceKeyEvent: BackspaceKeyEvent?
    var symbolKeyEventMap: [String: SymbolKeyEvent]!
    
	var currentWord: String = "" {
		didSet {
			updateAutoCorrectionSelector()
		}
	}
	var autoCorrectionSelector: AutoCorrectionSelector {
		return self.bannerView as! AutoCorrectionSelector
	}
    
    var emotion: Emotion?
    var hasAssessedEmotion: Bool { return emotion != nil }
    var timer: Timer!
    var assessmentSheet: PAMAssessmentSheet!
	var defaults: UserDefaults { return UserDefaults.standard }	
	
	let lastOpenThreshold: TimeInterval = 5.0
	let keepUsingThreshold: TimeInterval = 10.0
	
	class var kHasAssessedEmotion: String { return "KeyboardHasAssessedEmotion" }
	class var kKeepUsingTime: String { return "KeyboardKeepUsingTime" }
	class var kLastOpenTime: String { return "KeyboardLastOpenTime" }
    
    override public func viewDidLoad() {
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
		if defaults.object(forKey: KeymochiKeyboardViewController.kHasAssessedEmotion) == nil {
			defaults.set(false, forKey: KeymochiKeyboardViewController.kHasAssessedEmotion)
		}
		if defaults.object(forKey: KeymochiKeyboardViewController.kKeepUsingTime) == nil {
			defaults.set(0.0, forKey: KeymochiKeyboardViewController.kKeepUsingTime)
		}
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("will disappear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        motionManager.stopDeviceMotionUpdates()
        if hasAssessedEmotion {
            DataManager.sharedInatance.dumpCurrentData(withEmotion: emotion!)
        }
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
		
		if let word = textDocumentProxy.documentContextBeforeInput?.components(separatedBy: " ").last! {
			currentWord = word
		}
        if key == " " {
			if let firstGuess = getSuggestedWords()?.gussess.first {
				replaceWord(replacement: firstGuess)
			}
			currentWord = ""
        } else {
			currentWord += key
		}
    }
	
	private func getSuggestedWords() -> (completions: [String], gussess: [String])? {
		let textChecker = UITextChecker()
		let range = NSRange(location: 0, length: currentWord.characters.count)
		let completions: [String] = textChecker.completions(forPartialWordRange: range, in: currentWord, language: "en_US")!
		var guesses: [String]
		let misspelledRange = textChecker.rangeOfMisspelledWord(
			in: currentWord, range: range, startingAt: 0, wrap: false, language: "en_US")
		if misspelledRange.location != NSNotFound {
			guesses = textChecker.guesses(forWordRange: range, in: currentWord, language: "en_US")!
		} else {
			guesses = [currentWord]
		}
		return (completions, guesses)
	}
	
	func replaceWord(replacement: String){
		for _ in 0..<currentWord.characters.count {
			textDocumentProxy.deleteBackward()
		}
		textDocumentProxy.insertText(replacement)
	}
	
	private func updateAutoCorrectionSelector() {
		if currentWord == "" {
			(self.bannerView as! AutoCorrectionSelector).updateButtonArray(words: [])
		} else if let completions = getSuggestedWords()?.completions.filter({ $0 != currentWord }) {
			var partialGuesses: [String]
			if completions.count < 2 {
				partialGuesses = ["\"" + currentWord + "\""] + completions
			} else {
				partialGuesses = ["\"" + currentWord + "\""] + Array(completions[0...1])
			}
			self.autoCorrectionSelector.updateButtonArray(words: partialGuesses)
		} else {
			self.autoCorrectionSelector.updateButtonArray(words: ["\"" + currentWord + "\""])
		}
	}
	
    override func symbolKeyDown(_ sender: KeyboardKey) {
        switchAssessmentState()
        guard let key = self.layout?.keyForView(key: sender)?.outputForCase(self.shiftState.uppercase()) else {
            return
        }
        
        let symbolKeyEvent = SymbolKeyEvent()
        symbolKeyEvent.downTime = CACurrentMediaTime()
        symbolKeyEvent.key = key
        symbolKeyEventMap[key] = symbolKeyEvent
    }
    
    override func backspaceDown(_ sender: KeyboardKey) {
        switchAssessmentState()
        let keyEvent = BackspaceKeyEvent()
        keyEvent.downTime = CACurrentMediaTime()
        backspaceKeyEvent = keyEvent
		if let word = textDocumentProxy.documentContextBeforeInput?.components(separatedBy: " ").last! {
			currentWord = word
			if currentWord != "" {
				currentWord.remove(at: currentWord.index(before: currentWord.endIndex))
			}
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

    func switchAssessmentState() {
		
		if defaults.object(forKey: KeymochiKeyboardViewController.kLastOpenTime) == nil {
			defaults.set(Date(), forKey: KeymochiKeyboardViewController.kLastOpenTime)
		}
		
		let hasAssessedEmotion = defaults.bool(forKey: KeymochiKeyboardViewController.kHasAssessedEmotion)
		let lastOpenTimeInterval = -(defaults.object(forKey: KeymochiKeyboardViewController.kLastOpenTime) as! Date).timeIntervalSince(Date())
		let keepUsingTime = defaults.double(forKey: KeymochiKeyboardViewController.kKeepUsingTime)
		
		if lastOpenTimeInterval < lastOpenThreshold {
			defaults.set(keepUsingTime + lastOpenTimeInterval, forKey: KeymochiKeyboardViewController.kKeepUsingTime)
		} else {
			defaults.set(0.0, forKey: KeymochiKeyboardViewController.kKeepUsingTime)
		}
		
		if hasAssessedEmotion && lastOpenTimeInterval > lastOpenThreshold {
			defaults.set(false, forKey: KeymochiKeyboardViewController.kHasAssessedEmotion)
		} else if !hasAssessedEmotion && keepUsingTime > keepUsingThreshold {
			promptAssessmentSheet()
		}
		defaults.set(Date(), forKey: KeymochiKeyboardViewController.kLastOpenTime)
	}
	
	func promptAssessmentSheet() {
        assessmentSheet = PAMAssessmentSheet(frame: self.view.bounds, option: .intermediate)
        assessmentSheet.backgroundColor = UIColor.yellow
        assessmentSheet.delegate = self
        view.addSubview(assessmentSheet)
    }
}

// MARK: - AutoCorrectionSelectorDelegate Methods
extension KeymochiKeyboardViewController: AutoCorrectionSelectorDelegate {
	func autoCorrectionSelector(_: AutoCorrectionSelector, correctWithWord word: String) {
		var replacement = word
		if replacement[replacement.startIndex] == "\"" {
			replacement = replacement.replacingOccurrences(of: "\"", with: "")
		}
		replaceWord(replacement: replacement)
		currentWord = ""
	}
}

// MARK: - PAMAssessmentSheetDelegate Methods
extension KeymochiKeyboardViewController: PAMAssessmentSheetDelegate {
    public func assessmentSheet(_: PAMAssessmentSheet, didSelectEmotion emotion: Emotion) {
        self.emotion = emotion
        assessmentSheet.removeFromSuperview()
        defaults.set(true, forKey: KeymochiKeyboardViewController.kHasAssessedEmotion)
    }
}
