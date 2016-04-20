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
    let segmentedControlWidth = UIScreen.mainScreen().bounds.width - 30
    emotionSegmentedControl = UISegmentedControl.init(frame: CGRect(x: 15, y: 7, width: segmentedControlWidth, height: 30))
    for (index, emotion) in Emotion.all.enumerate() {
      emotionSegmentedControl
        .insertSegmentWithTitle(emotion.description, atIndex: index, animated: false)
    }
    
    if let emotion = dataChunk.emotion {
      emotionSegmentedControl.selectedSegmentIndex = Emotion.all.indexOf(emotion)!
    }
    
    emotionSegmentedControl.addTarget(self, action: #selector(changeEmotion(_:)), forControlEvents: UIControlEvents.ValueChanged)
    
    emotionContainer.addSubview(emotionSegmentedControl)
  }
  
  func changeEmotion(sender: UISegmentedControl) {
    let emotion = Emotion.all[sender.selectedSegmentIndex]
    DataManager.sharedInatance.updateDataChunk(dataChunk, withEmotion: emotion)
  }
  
  @IBAction func uploadDataChunk(sender: AnyObject) {
    let object = PFObject(className: "DataChunk")
    
    if let userId = NSUserDefaults.standardUserDefaults().objectForKey("userid_preference") {
      object.setObject(userId, forKey: "userId")
    }
    
    var emotion: Emotion!
    if emotionSegmentedControl.selectedSegmentIndex != -1 {
      emotion = Emotion.all[emotionSegmentedControl.selectedSegmentIndex]
      object.setObject(emotion.description, forKey: "emotion")
    } else {
      let alert = UIAlertController.init(title: "Error", message: "Please specify the associated emotion for this data chunk.", preferredStyle: .Alert)
      alert.addAction(UIAlertAction.init(title: "OK", style: .Default, handler: nil))
      self.presentViewController(alert, animated: true, completion: nil)
      return
    }
    
    if let symbolCounts = dataChunk.symbolCounts {
      for (symbol, count) in symbolCounts {
        if symbol == " " {
          object.setObject(count, forKey: "symbol_space")
        } else {
          for scalar in symbol.unicodeScalars {
            let value = scalar.value
            if (value >= 65 && value <= 90) || (value >= 97 && value <= 122) || (value >= 48 && value <= 57) {
              object.setObject(count, forKey: "symbol_\(symbol)")
            } else {
              object.setObject(count, forKey: "symbol_punctuation")
            }
          }
        }
      }
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
    
    object.saveInBackgroundWithBlock { (success, error) in
      if let error = error {
        let alert = UIAlertController.init(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
      } else if let parseId = object.objectId {
        DataManager.sharedInatance.updateDataChunk(self.dataChunk, withEmotion: emotion, andParseId: parseId)
        let alert = UIAlertController.init(title: "DataChunk", message: "Successfully uploaded! \(self.dataChunk.parseId)", preferredStyle: .Alert)
        alert.addAction(UIAlertAction.init(title: "Done", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
      }
    }
  }
  
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    guard let identifier = segue.identifier else {
      return
    }
    
    let vc = segue.destinationViewController as! DataChunkDetailsTableViewController
    func bindData(data: [String], andTimestamps timeStamps: [String]?, withTitle title: String) {
      vc.data = data
      vc.timestamps = timeStamps
      vc.title = "\(title) (\(data.count))"
    }
    
    switch identifier {
    case "ShowKey":
      bindData(dataChunk.keyEvents?.map { $0.description } ?? [],
               andTimestamps: dataChunk.keyEvents?.map { $0.timestamp} ?? [],
               withTitle: "Key")
    case "ShowITD":
      bindData(dataChunk.interTapDistances?.map(String.init) ?? [],
               andTimestamps: nil,
               withTitle: "Inter-Tap Distance")
    case "ShowAcceleration":
      bindData(dataChunk.accelerationDataPoints?.map { $0.description } ?? [],
               andTimestamps: dataChunk.accelerationDataPoints?.map { $0.timestamp } ?? [],
               withTitle: "Acceleration")
    case "ShowGyro":
      bindData(dataChunk.gyroDataPoints?.map { $0.description } ?? [],
               andTimestamps: dataChunk.gyroDataPoints?.map { $0.timestamp } ?? [],
               withTitle: "Gyro")
    default:
      break
    } 
  }
}
