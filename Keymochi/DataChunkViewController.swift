//
//  DataChunkViewController.swift
//  Keymochi
//
//  Created by Huai-Che Lu on 4/7/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import UIKit
import Parse

class DataChunkViewController: UITableViewController {
  
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
    
    emotionContainer.addSubview(emotionSegmentedControl)
  }
  
  @IBAction func uploadDataChunk(sender: AnyObject) {
    let object = PFObject(className: "DataChunk")
    let emotion = Emotion.all[emotionSegmentedControl.selectedSegmentIndex]
    
    if let userId = NSUserDefaults.standardUserDefaults().objectForKey("userid_preference") {
      object.setObject(userId, forKey: "userId")
    }
    
    object.setObject(emotion.description, forKey: "emotion")
    object.setObject(dataChunk.symbolCounts!, forKey: "symbolKeyCounts")
    object.setObject(dataChunk.totalNumberOfDeletions!, forKey: "totoalNumberOfDeletions")
    object.setObject(dataChunk.interTapDistances!, forKey: "interTapDistances")
    object.setObject(dataChunk.tapDurations!, forKey: "tapDurations")
    object.setObject(dataChunk.accelerationMagnitudes!, forKey: "accelerationMagnitudes")
    object.setObject(dataChunk.gyroMagnitudes!, forKey: "gyroMagnitudes")
    
    object.saveInBackgroundWithBlock { (success, error) in
      guard error == nil else {
        return
      }
      let alert = UIAlertController.init(title: "DataChunk", message: "Successfully uploaded!", preferredStyle: .Alert)
      alert.addAction(UIAlertAction.init(title: "Done", style: .Default, handler: nil))
      self.presentViewController(alert, animated: true, completion: nil)
    }
  }
  
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    guard let identifier = segue.identifier else {
      return
    }
    
    let vc = segue.destinationViewController as! DataChunkDetailsTableViewController
    func bindData(data: [String], withTitle title: String) {
      vc.data = data
      vc.title = "\(title) (\(data.count))"
    }
    
    switch identifier {
    case "ShowKey":
      bindData(dataChunk.keyEvents?
          .map { "\($0.upTime)" } ?? [],
        withTitle: "Key")
      
    case "ShowITD":
      bindData(dataChunk.interTapDistances?
          .map(String.init) ?? [],
        withTitle: "Inter-Tap Distance")
      
    case "ShowAcceleration":
      bindData(dataChunk.accelerationDataPoints?
          .map { $0.description } ?? [],
        withTitle: "Acceleration")
      
    case "ShowGyro":
      bindData(dataChunk.gyroDataPoints?
        .map { $0.description } ?? [],
               withTitle: "Gyro")
      
    default:
      break
    }
    
    
    
  }
  
  
}
