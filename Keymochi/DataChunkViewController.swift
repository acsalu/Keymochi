//
//  DataChunkViewController.swift
//  Keymochi
//
//  Created by Huai-Che Lu on 4/7/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import UIKit
import Parse

class DataChunkViewController: UIViewController {
  
  var dataChunk: DataChunk!
  var emotionSegmentedControl: UISegmentedControl!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    emotionSegmentedControl = UISegmentedControl.init(frame: CGRect(x: 15, y: 100, width: 345, height: 30))
    for (index, emotion) in Emotion.all.enumerate() {
      emotionSegmentedControl
        .insertSegmentWithTitle(emotion.description, atIndex: index, animated: false)
    }
    
    view.addSubview(emotionSegmentedControl)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(false, animated: true)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func uploadDataChunk(sender: AnyObject) {
    let object = PFObject(className: "DataChunkTest")
    let emotion = Emotion.all[emotionSegmentedControl.selectedSegmentIndex]
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
      
      print("success")
    }
  }
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
