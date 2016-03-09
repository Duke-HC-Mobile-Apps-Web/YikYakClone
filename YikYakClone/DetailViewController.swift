//
//  DetailViewController.swift
//  YikYakClone
//
//  Created by Jesse Hu on 2/15/16.
//  Copyright © 2016 Jesse Hu. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDataSource, PostTableViewCellDelegate {

    @IBOutlet var yakTextView: UITextView!
    @IBOutlet var voteCountLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var repliesLabel: UILabel!
    @IBOutlet var replyTextField: UITextField!
    @IBOutlet var replyContainer: UIView!               //We use this to shift the reply box up when the keyboard is shown
    
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
        }
    }
    
    var yak: Yak?
    
    @IBAction func shareButtonPressed(sender: UIButton) {
        // TODO: Share Button (in class)
    }
    
    @IBAction func postButtonPressed(sender: UIButton) {
        let reply = Reply(text: replyTextField.text!, timestamp: NSDate(), location: nil)
        
        // TODO: what to do with the reply?
        YakCenter.sharedInstance.postReply(reply, yak: yak!)
        replyTextField.text = reply.text
        self.dismissViewControllerAnimated(true, completion: nil)
        
        //YakCenter.sharedInstance.replyFeedDelegate = self
        
        
        //resignFirstResponder hides the keyboard
        replyTextField.resignFirstResponder()
        replyTextField.text = ""
    }
    
    func replyAddedToFeed() {
        //the YakCenter told us that there are new yaks available, so add them to the feed
        self.tableView.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        replyTextField.autocorrectionType = .No
        
        YakCenter.sharedInstance.subscribeToRepliesForYak(yak!)
        showYakInfo()
        
        
        //subscribe to notifications for when the keyboard appears and disappears
        //we use these notifications to shift the comment box up and down as needed
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillAppear:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillDisappear:", name: UIKeyboardWillHideNotification, object: nil)

        // Do any additional setup after loading the view.
    }
    
    func showYakInfo() {
        //display Yak info
        yakTextView.text = yak?.text
        voteCountLabel.text = String(yak!.netVoteCount)
        timeLabel.text = yak?.timestampToReadable()
        
        let replyText = yak!.replies.count == 1 ? "1 Reply" : "\(yak!.replies.count) Replies"
        repliesLabel.text = replyText
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.toolbar.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let yak = yak {
            return yak.replies.count
        } else {
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("replyCell", forIndexPath: indexPath) as! ReplyTableViewCell
        
        // Set delegate
        cell.delegate = self
        cell.indexPath = indexPath
        
        let reply: Reply! = yak?.replies[indexPath.row]
        
        cell.textView.text = reply.text
        
        cell.timeLabel.text = reply.timestampToReadable()
        
        cell.voteCountLabel.text = String(reply.netVoteCount)
        
        return cell
    }
    
    // MARK: - PostTableViewCell delegate
    
    func didUpvoteCellAtIndexPath(indexPath: NSIndexPath) {
        if let reply = yak?.replies[indexPath.row] {
            reply.netVoteCount += 1
            let cell = tableView.cellForRowAtIndexPath(indexPath) as? PostTableViewCell
            cell?.voteCountLabel.text = String(reply.netVoteCount)
        }

    }
    
    func didDownvoteCellAtIndexPath(indexPath: NSIndexPath) {
        if let reply = yak?.replies[indexPath.row] {
            reply.netVoteCount -= 1
            let cell = tableView.cellForRowAtIndexPath(indexPath) as? PostTableViewCell
            cell?.voteCountLabel.text = String(reply.netVoteCount)
        }
    }
    
    // MARK: keyboard
    
    func keyboardWillAppear(notification: NSNotification){
        if let userInfo = notification.userInfo, keyboardSizeValue = userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue {
            let keyboardSize = keyboardSizeValue.CGRectValue()
            //we slide the reply box and send button up the size of the keyboard - the size of the bottom tab bar
            if let tabBarController = self.tabBarController {
                replyContainer.transform = CGAffineTransformMakeTranslation(0, -keyboardSize.height + tabBarController.tabBar.frame.height)
            }

        }
    }
    
    func keyboardWillDisappear(notification: NSNotification){
        replyContainer.transform = CGAffineTransformIdentity
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
