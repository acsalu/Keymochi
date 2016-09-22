//
//  DataChunkViewController.swift
//  Keymochi
//
//  Created by Huai-Che Lu on 4/7/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import Foundation
import UIKit

import RealmSwift
import Firebase
import FirebaseAnalytics
import FirebaseDatabase

class DataChunkViewController: UITableViewController {
    
    var dataChunk: DataChunk!
    var emotionSegmentedControl: UISegmentedControl!
    var uid: String!
    
    @IBOutlet weak var emotionContainer: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let segmentedControlWidth = UIScreen.main.bounds.width - 30
        emotionSegmentedControl = UISegmentedControl.init(frame: CGRect(x: 15, y: 7, width: segmentedControlWidth, height: 30))
        for (index, emotion) in Emotion.all.enumerated() {
            emotionSegmentedControl
                .insertSegment(withTitle: emotion.description, at: index, animated: false)
        }
        
        if let emotion = dataChunk.emotion, let index = Emotion.all.index(of: emotion) {
            emotionSegmentedControl.selectedSegmentIndex = index
        }
        
        emotionSegmentedControl.addTarget(self, action: #selector(changeEmotion(_:)), for: UIControlEvents.valueChanged)
        
        emotionContainer.addSubview(emotionSegmentedControl)
    }
    
    func changeEmotion(_ sender: UISegmentedControl) {
        let emotion = Emotion.all[sender.selectedSegmentIndex]
        DataManager.sharedInatance.updateDataChunk(dataChunk, withEmotion: emotion)
    }
    
    func alertSetupUserId() {
        let alert = UIAlertController.init(title: "Error", message: "Please set your userId by going to Settings --> Keymochi --> And Enter a Value in the UserID field", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func uploadDataChunk(_ sender: AnyObject) {
        
        guard let uid = UserDefaults.standard.object(forKey: "userid_preference") as? String else {
            alertSetupUserId()
            return
        }
        
        guard !uid.isEmpty else {
            alertSetupUserId()
            return
        }
        
        guard emotionSegmentedControl.selectedSegmentIndex != -1  else {
            let alert = UIAlertController.init(title: "Error", message: "Please label the emotion for this data chunk.", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        
        
        let emotion = Emotion.all[emotionSegmentedControl.selectedSegmentIndex]
        
        var childValues = [String: Any]()
        childValues["emotion"] = emotion.description
        childValues["user"] = uid
        
        guard let totalNumberOfDeletions = dataChunk.totalNumberOfDeletions,
                let interTapDistances = dataChunk.interTapDistances,
                let tapDurations = dataChunk.tapDurations,
                let accelerationMagnitudes = dataChunk.accelerationMagnitudes,
                let gyroMagnitudes = dataChunk.gyroMagnitudes,
                let appVersion = dataChunk.appVersion,
                let symbolCounts = dataChunk.symbolCounts else {
            return
        }
        
        childValues["totalNumDel"] = NSNumber(value: totalNumberOfDeletions)
        childValues["interTapDist"] = NSArray(array: interTapDistances.map { NSNumber(value: $0) })
        childValues["tapDur"] = NSArray(array: tapDurations.map { NSNumber(value: $0) })
        childValues["accelMag"] = NSArray(array: accelerationMagnitudes.map { NSNumber(value: $0) })
        childValues["gyroMag"] = NSArray(array: gyroMagnitudes.map { NSNumber(value: $0) })
        childValues["appVer"] = NSString(string: appVersion)
        
        var puncuationCount = 0
        for (symbol, count) in symbolCounts {
            for scalar in symbol.unicodeScalars {
                let value = scalar.value
                if (value >= 65 && value <= 90) || (value >= 97 && value <= 122) || (value >= 48 && value <= 57) {
                    childValues["symbol_\(symbol)"] = NSNumber(value: count)
                } else {
                    puncuationCount += count
                    var key: String!
                    switch symbol {
                    case " ":
                        key = "symbol_space"
                    case "!":
                        key = "symbol_exclamation_mark"
                    case ".":
                        key = "symbol_period"
                    case "?":
                        key = "symbol_question_mark"
                    default:
                        continue
                    }
                    childValues[key] = NSNumber(value: count)
                }
            }
            childValues["symbol_punctuation"] = NSNumber(value: puncuationCount)
        }
        
        var databaseReference: FIRDatabaseReference!
        if let key = dataChunk.firebaseKey {
            let id = key.components(separatedBy: "/").last!
            databaseReference = FIRDatabase.database().reference().child("users").child(uid).child(id)
        } else {
            databaseReference = FIRDatabase.database().reference().child("users").child(uid).childByAutoId()
        }
        
        databaseReference.updateChildValues(childValues) { (error, refernce) in
            if error == nil {
                try! DataManager.sharedInatance.realm.write { self.dataChunk.firebaseKey = refernce.url }
            }
            
            let title = error == nil ? "Success" : "Error"
            let message = error == nil ? "The data has been uploaded successfully" : "There was a problem uploading the Data, please try again!"
            let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }

    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        
        let vc = segue.destination as! DataChunkDetailsTableViewController
        func bindData(_ data: [String], andTimestamps timeStamps: [String]?, withTitle title: String) {
            vc.data = data
            vc.timestamps = timeStamps
            vc.title = "\(title) (\(data.count))"
        }
        
        switch identifier {
        case "ShowKey":
            bindData(dataChunk.keyEvents?.map { $0.description } ?? [],
                     andTimestamps: dataChunk.keyEvents?.map { $0.timestamp } ?? [],
                     withTitle: "Key")
        case "ShowITD":
            bindData(dataChunk.interTapDistances?.map(String.init) ?? [],
                     andTimestamps: nil,
                     withTitle: "Inter-Tap Distance")
        case "ShowAcceleration":
            bindData(dataChunk.accelerationDataPoints?.map { $0.description } ?? [],
                     andTimestamps: dataChunk.accelerationDataSequence?.timestamps ?? [],
                     withTitle: "Acceleration")
        case "ShowGyro":
            bindData(dataChunk.gyroDataPoints?.map { $0.description } ?? [],
                     andTimestamps: dataChunk.gyroDataSequence?.timestamps ?? [],
                     withTitle: "Gyro")
        default:
            break
        } 
    }
}
