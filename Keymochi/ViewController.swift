//
//  ViewController.swift
//  Keymochi
//
//  Created by Huai-Che Lu on 2/28/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftDate

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var realm: Realm!
    var keyEvents = [KeyEvent]()
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
        let symbolKeyEvents = Array(realm.objects((SymbolKeyEvent)))
        let backspaceKeyEvents = Array(realm.objects(BackspaceKeyEvent))
        keyEvents = (symbolKeyEvents as [KeyEvent]) + (backspaceKeyEvents as [KeyEvent])
        
        // Reverse chronological order
        keyEvents.sortInPlace {
            return $0.downTime > $1.downTime
        }
        self.eventHistoryTableView.reloadData()
        
        let dataChunks = Array(realm.objects(DataChunk))
        for dataChunk in dataChunks {
            print(dataChunk)
        }
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
        return keyEvents.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let keyEvent = keyEvents[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("KeyEventCell", forIndexPath: indexPath)
        
        let keyLabel      = cell.viewWithTag(100) as! UILabel
        let durationLabel = cell.viewWithTag(101) as! UILabel
        let downTimeLabel = cell.viewWithTag(102) as! UILabel
        let upTimeLabel   = cell.viewWithTag(103) as! UILabel
        
        if let symbolKeyEvent = keyEvent as? SymbolKeyEvent {
            keyLabel.text = symbolKeyEvent.key!
        } else if let backspaceKeyEvent = keyEvent as? BackspaceKeyEvent {
            keyLabel.text = String(format: "← (%d)", backspaceKeyEvent.numberOfDeletions)
        }
        
        downTimeLabel.text = "\(keyEvent.downTime)"
        upTimeLabel.text = "\(keyEvent.upTime)"
        durationLabel.text = String(format: "%.1f ms", (keyEvent.upTime - keyEvent.downTime) * 1000)
        
        return cell
    }
}

