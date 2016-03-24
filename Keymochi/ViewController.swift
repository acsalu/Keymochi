//
//  ViewController.swift
//  Keymochi
//
//  Created by Huai-Che Lu on 2/28/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  var realm: Realm!
  var dataChunks = [DataChunk]()
  @IBOutlet weak var eventHistoryTableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    let directoryURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(Constants.groupIdentifier)
    let realmPath = directoryURL?.URLByAppendingPathComponent("db.realm").path
    self.realm = try! Realm.init(path: realmPath!)
    
    reloadData()
  }
  
  override func viewWillAppear(animated: Bool) {
    reloadData()
  }
  
  func reloadData() {
    
    self.dataChunks = Array(realm.objects(DataChunk))
    self.eventHistoryTableView.reloadData()
  }
  
  @IBAction func removeAllData(sender: AnyObject) {
    
    let alertController = UIAlertController.init(title: "Delete Data", message: "Are you sure to delete all data?", preferredStyle: .Alert)
    let actionDelete = UIAlertAction.init(title: "Delete", style: .Destructive) { alertAction -> Void in
      self.realm.beginWrite()
      self.realm.deleteAll()
      try! self.realm.commitWrite()
      self.reloadData()
    }
    
    let actionCancel = UIAlertAction.init(title: "Cancel", style: .Cancel) { alertAction -> Void in
      
    }
    
    alertController.addAction(actionCancel)
    alertController.addAction(actionDelete)
    
    self.presentViewController(alertController, animated: true, completion: nil)
    
  }
  
  // MARK: - UITableViewDataSource methods
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataChunks.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let dataChunk = dataChunks[indexPath.row]
    
    let cell = tableView.dequeueReusableCellWithIdentifier("KeyEventCell", forIndexPath: indexPath)
    
    let emotionLabel      = cell.viewWithTag(100) as! UILabel
    let durationLabel = cell.viewWithTag(101) as! UILabel
    let keyEventCountLabel = cell.viewWithTag(102) as! UILabel
    let motionDataPointCountLabel   = cell.viewWithTag(103) as! UILabel
    
    emotionLabel.text = dataChunk.emotion.description
    durationLabel.text = String(format: "%.1f ms", (dataChunk.endTime! - dataChunk.startTime!) * 1000)
    keyEventCountLabel.text = String(format: "%d key events", dataChunk.keyEvents.count)
    motionDataPointCountLabel.text =
      String(format: "%d motion data points",
             dataChunk.accelerationDataPoints.count + dataChunk.gyroDataPoints.count)
    
    return cell
  }
}

