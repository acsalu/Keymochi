//
//  DraftViewController.swift
//  Keymochi
//
//  Created by Huai-Che Lu on 3/3/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import UIKit

class DraftViewController: UIViewController {
  
  @IBOutlet weak var textView: UITextView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    let tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(DraftViewController.dismissKeyboardOnTap(_:)))
    let swipeDownRecognizer = UISwipeGestureRecognizer.init(target: self, action: #selector(DraftViewController.dismissKeyboardOnTap(_:)))
    swipeDownRecognizer.direction = .Down
    self.view.addGestureRecognizer(tapRecognizer)
    self.view.addGestureRecognizer(swipeDownRecognizer)
  }
  
  func dismissKeyboardOnTap(sender: AnyObject) {
    self.view.endEditing(true)
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
