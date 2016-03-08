//
//  YakCenter.swift
//  YikYakClone
//
//  Created by Davis Gossage on 2/20/16.
//  Copyright © 2016 Jesse Hu. All rights reserved.
//

import UIKit
import Firebase

protocol YakFeedDelegate{
    func yakAddedToFeed()
}

protocol ReplyFeedDelegate{
    func replyAddedToFeed()
}

class YakCenter: NSObject {
    static let sharedInstance = YakCenter()
    var yakFeedDelegate: YakFeedDelegate?
    var replyFeedDelegate: ReplyFeedDelegate?
    
    //this is our base reference to our firebase database
    static let baseURL = "https://yik-yak-clone.firebaseio.com"
    let baseRef = Firebase(url: "\(baseURL)")
    let yakRef = Firebase(url: "\(baseURL)/yaks")
    let replyRef = Firebase(url: "\(baseURL)/replies")
    
    var allYaks = [Yak]()
    
    var subscribedReplyHandle: UInt?
    
    //store a dictionary which keeps track of votes made locally
    var voteDictionary: Dictionary<String, Bool>
    
    override init() {
        let voteRecord = NSUserDefaults.standardUserDefaults().objectForKey("voteRecord")
        if (voteRecord == nil){
            self.voteDictionary = Dictionary<String, Bool>()
        }
        else{
            self.voteDictionary = voteRecord as! Dictionary<String, Bool>
        }
        super.init()
        //we setup listeners for when remote data changes, this is the primary way of reading data via firebase
        yakRef.queryOrderedByChild("timestamp").observeEventType(.Value, withBlock: { snapshot in
            self.allYaks.removeAll()
            //here we get all of the yaks (children), and make sure there is at least 1
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot]{
                for yakSnapshot in snapshots{
                    self.allYaks.append(Yak(dictionary: yakSnapshot.value as! Dictionary<String, AnyObject>, snapshot: yakSnapshot))
                }
            }
            self.yakFeedDelegate?.yakAddedToFeed()
        })
    }
    
    /**
     When the detail view controller wants to subscribe to the replies for a given yak, it should use this method
    */
    func subscribeToRepliesForYak(yak: Yak){
        //cancel existing subscription if there is one
        if (subscribedReplyHandle != nil){
            replyRef.removeObserverWithHandle(subscribedReplyHandle!)
        }
        
        /*****
        this is similar to where we listen for Yaks above, but replies are stored by the Yak ID which is why there is an extra 'childByAppendingPath'
        so remember our database looks like this, where the 1 represents a unique identifier for a Yak and the R1 represents a unique identifier for the Reply
                        yaks{
                            1: {yak info...}
                        }
                        replies{
                            1: {
                                R1: {reply info...}
                                }
                        }
        ******/
        subscribedReplyHandle = replyRef.childByAppendingPath(yak.snapshot!.key).observeEventType(.Value, withBlock: { snapshot in
            yak.replies.removeAll()
            //here we get all of the replies (children), convert them to snapshots, and make sure there is at least 1
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot]{
                for replySnapshot in snapshots{
                    yak.replies.append(Reply(dictionary: replySnapshot.value as! Dictionary<String, AnyObject>, snapshot: replySnapshot))
                }
            }
            self.replyFeedDelegate?.replyAddedToFeed()
        })
    }
    
    func postYak(yak: Yak){
        let newYakRef = yakRef.childByAutoId()
        newYakRef.setValue(yak.toDictionary())
    }
    
    func postReply(reply: Reply, yak: Yak){
        //we store replies under the id of the yak, then under a unique id for the reply
        let newReplyRef = replyRef.childByAppendingPath(yak.snapshot!.key).childByAutoId()
        newReplyRef.setValue(reply.toDictionary())
    }
    
    func voteOnYak(yak: Yak, upvote: Bool){
        //check to see if vote is eligible
        if (voteDictionary[yak.snapshot!.key] == nil){
            voteDictionary[yak.snapshot!.key] = true
            NSUserDefaults.standardUserDefaults().setObject(voteDictionary, forKey: "voteRecord")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            let voteRef = yakRef.childByAppendingPath(yak.snapshot!.key + "/votes")
            voteRef.runTransactionBlock({
                (currentData: FMutableData!) in
                let currentVotes = currentData.value as! Int
                if (upvote){
                    currentData.value = currentVotes + 1
                }
                else{
                    currentData.value = currentVotes - 1
                }
                return FTransactionResult.successWithValue(currentData)
            })
        }
    }
}
