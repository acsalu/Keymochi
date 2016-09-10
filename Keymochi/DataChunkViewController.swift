//
//  DataChunkViewController.swift
//  Keymochi
//
//  Created by Huai-Che Lu on 4/7/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import UIKit
import Parse
import RealmSwift

class DataChunkViewController: UITableViewController {
  
  var realm: Realm!
  var dataChunk: DataChunk!
  var emotionSegmentedControl: UISegmentedControl!
  
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
  
  @IBAction func uploadDataChunk(_ sender: AnyObject) {
    let object = PFObject(className: "DataChunk")
    
    if let userId = UserDefaults.standard.object(forKey: "userid_preference") {
      object.setObject(userId, forKey: "userId")
    }
    
    var emotion: Emotion!
    if emotionSegmentedControl.selectedSegmentIndex != -1 {
      emotion = Emotion.all[emotionSegmentedControl.selectedSegmentIndex]
      object.setObject(emotion.description, forKey: "emotion")
    } else {
      let alert = UIAlertController.init(title: "Error", message: "Please label the emotion for this data chunk.", preferredStyle: .alert)
      alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
      self.present(alert, animated: true, completion: nil)
      return
    }
    
    if let symbolCounts = dataChunk.symbolCounts {
      var puncuationCount = 0
      for (symbol, count) in symbolCounts {
        for scalar in symbol.unicodeScalars {
          let value = scalar.value
          if (value >= 65 && value <= 90) || (value >= 97 && value <= 122) || (value >= 48 && value <= 57) {
            object.setObject(count, forKey: "symbol_\(symbol)")
          } else {
            puncuationCount += count
            switch symbol {
            case " ":
              object.setObject(count, forKey: "symbol_space")
            case "!":
              object.setObject(count, forKey: "symbol_exclamation_mark")
            case ".":
              object.setObject(count, forKey: "symbol_period")
            case "?":
              object.setObject(count, forKey: "symbol_question_mark")
            default:
              continue
            }
          }
        }
      }
      object.setObject(puncuationCount, forKey: "symbol_punctuation")
    }
    
    if let totalNumberOfDeletions = dataChunk.totalNumberOfDeletions {
      object.setObject(totalNumberOfDeletions, forKey: "totalNumberOfDeletions")
    }
    
    if let interTapDistances = dataChunk.interTapDistances {
      object.setObject(interTapDistances, forKey: "interTapDistances")
    }
    
    if let tapDurations = dataChunk.tapDurations {
      object.setObject(tapDurations, forKey: "tapDurations")
    }
    
    if let accelerationMagnitudes = dataChunk.accelerationMagnitudes {
      object.setObject(accelerationMagnitudes, forKey: "accelerationMagnitudes")
    }
    
    if let gyroMagnitudes = dataChunk.gyroMagnitudes {
      object.setObject(gyroMagnitudes, forKey: "gyroMagnitudes")
    }
    
    if let appVersion = dataChunk.appVersion {
      object.setObject(appVersion, forKey: "appVersion")
    }
    
    object.saveInBackground { (success, error) in
      if let error = error {
        let alert = UIAlertController.init(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
      } else if let parseId = object.objectId {
        DataManager.sharedInatance.updateDataChunk(self.dataChunk, withEmotion: emotion, andParseId: parseId)
        let alert = UIAlertController.init(title: "DataChunk", message: "Successfully uploaded! \(self.dataChunk.parseId)", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "Done", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
      }
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
