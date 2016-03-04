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
    
    func reloadData() {
        keyEvents = Array(realm.objects(KeyEvent))
        self.eventHistoryTableView.reloadData()
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
        
        let keyLabel      = cell.viewWithTag(100) as? UILabel
        let durationLabel = cell.viewWithTag(101) as? UILabel
        let downTimeLabel = cell.viewWithTag(102) as? UILabel
        let upTimeLabel   = cell.viewWithTag(103) as? UILabel
        
        keyLabel?.text = keyEvent.key!
        downTimeLabel?.text = "\(keyEvent.downTime)"
        upTimeLabel?.text = "\(keyEvent.upTime)"
        
        durationLabel?.text = String(format: "%.1f ms", (keyEvent.upTime - keyEvent.downTime) * 1000)
        
        return cell
    }
}

