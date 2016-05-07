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
  @IBOutlet weak var doneButtonBottomConstraint: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(DraftViewController.dismissKeyboardOnTap(_:)))
    let swipeDownRecognizer = UISwipeGestureRecognizer.init(target: self, action: #selector(DraftViewController.dismissKeyboardOnTap(_:)))
    swipeDownRecognizer.direction = .Down
    view.addGestureRecognizer(tapRecognizer)
    view.addGestureRecognizer(swipeDownRecognizer)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
  }
  
  override func viewWillDisappear(animated: Bool) {
    NSNotificationCenter.defaultCenter().removeObserver(self)
    super.viewWillDisappear(animated)
  }
  
  func dismissKeyboardOnTap(sender: AnyObject) {
    dismissKeyboard()
  }
  
  @IBAction func doneButtonPressed(sender: AnyObject) {
    dismissKeyboard()
  }
  
  private func dismissKeyboard() {
    view.endEditing(true)
  }
  
  @IBAction func clearText(sender: AnyObject) {
    textView.text = ""
  }
  
  
  func keyboardWillShow(notification: NSNotification) {
    guard let userInfo = notification.userInfo else {
      return
    }
    
    guard let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() else {
      return
    }

    doneButtonBottomConstraint.constant = keyboardFrame.size.height - (tabBarController?.tabBar.frame.size.height ?? 0.0)
  }
  
  func keyboardWillHide(notification: NSNotification) {
    doneButtonBottomConstraint.constant = 0.0
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
