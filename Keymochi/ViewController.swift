//
//  ViewController.swift
//  Keymochi
//
//  Created by Huai-Che Lu on 2/28/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  var dataChunks = [DataChunk]()
  @IBOutlet weak var eventHistoryTableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    reloadData()
  }
  
  override func viewWillAppear(animated: Bool) {
    reloadData()
  }
  
  func reloadData() {
    dataChunks = DataManager.sharedInatance.getDataChunks()
    eventHistoryTableView.reloadData()
  }
  
  @IBAction func removeAllData(sender: AnyObject) {
    
    let alertController = UIAlertController.init(title: "Delete Data", message: "Are you sure to delete all data?", preferredStyle: .Alert)
    let actionDelete = UIAlertAction.init(title: "Delete", style: .Destructive) { alertAction -> Void in
      DataManager.sharedInatance.clearData()
      self.reloadData()
    }
    
    let actionCancel = UIAlertAction.init(title: "Cancel", style: .Cancel) { alertAction -> Void in
      
    }
    
    alertController.addAction(actionCancel)
    alertController.addAction(actionDelete)
    
    presentViewController(alertController, animated: true, completion: nil)
    
  }
  
  // MARK: - Navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "DataChunkDetails" {
      let vc: DataChunkViewController = segue.destinationViewController as! DataChunkViewController
      vc.dataChunk = sender! as! DataChunk
    }
  }
  
}


// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {

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
    let updatedAtLabel    = cell.viewWithTag(101) as! UILabel
    let parseIdLabel      = cell.viewWithTag(102) as! UILabel
    
    emotionLabel.text = dataChunk.emotion?.description ?? "(unlabeld)"
    parseIdLabel.text = dataChunk.parseId ?? "(unpushed)"
    updatedAtLabel.text = dataChunk.createdAt.description
    
    return cell
  }
}


// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    [self.performSegueWithIdentifier("DataChunkDetails", sender: dataChunks[indexPath.row])]
  }
}
