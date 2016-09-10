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
    swipeDownRecognizer.direction = .down
    view.addGestureRecognizer(tapRecognizer)
    view.addGestureRecognizer(swipeDownRecognizer)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    NotificationCenter.default.removeObserver(self)
    super.viewWillDisappear(animated)
  }
  
  func dismissKeyboardOnTap(_ sender: AnyObject) {
    dismissKeyboard()
  }
  
  @IBAction func doneButtonPressed(_ sender: AnyObject) {
    dismissKeyboard()
  }
  
  fileprivate func dismissKeyboard() {
    view.endEditing(true)
  }
  
  @IBAction func clearText(_ sender: AnyObject) {
    textView.text = ""
  }
  
  
  func keyboardWillShow(_ notification: Notification) {
    guard let userInfo = (notification as NSNotification).userInfo else {
      return
    }
    
    guard let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
      return
    }

    doneButtonBottomConstraint.constant = keyboardFrame.size.height - (tabBarController?.tabBar.frame.size.height ?? 0.0)
  }
  
  func keyboardWillHide(_ notification: Notification) {
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
