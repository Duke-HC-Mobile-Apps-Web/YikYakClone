# Instructions for HW due 03/09

In class we walked through saving/fetching Yak objects to/from Firebase.  YakCenter.swift contains all of the methods related to saving and fetching Yaks, and the view controllers call these methods as needed.  Here is how things work for saving and fetching Yaks:

* `ComposeViewController.swift` has a function createNewYak which initializes a Yak object, sets the instance variables through the initalizer (see Yak.swift) and then calls `YakCenter.sharedInstance.postYak()` where the Yak is saved to Firebase
* `PostTableViewController.swift` signs up to be the `YakFeedDelegate` which is a protocol found in `YakCenter`. By setting itself as YakCenter's delegate and conforming to the `YakFeedDelegate` protocol, the `PostTableViewController` is notified whenever there is a new Yak to be displayed.  It is notified by implementing the method called `yakAddedToFeed`. Finally, all that the `PostTableViewController` needs to do to get the new data is call `self.tableView.reloadData()`, which gets the new data from the `YakCenter` via the `Yaks()` function found on line 116 of `PostTableViewController.swift`.


##Assignment
We'd like you to get replies working in the app.  Start by forking this repo, and cloning your fork.  You'll notice that in addition to what we did in class, two new functions and one new protocol were added to `YakCenter`.  They are:

* subscribeToRepliesForYak
	* This function sets up a listener for a Yak's replies.  In the same way we listen for new Yak's getting added to the feed, we want to listen to replies that get added to whatever Yak we are looking at. You shouldn't need to do anything with this function, as it is already being called from the DetailViewController, line 46.
* postReply
	* This function saves a reply to Firebase.  You'll need to figure out where in the app to call this.
* ReplyFeedDelegate
	* This protocol alerts whoever signs up to be the delegate whenever a reply gets added to the feed.  You'll need to figure out what view controller should sign up to be the delegate, and what action that view controller should take when `replyAddedToFeed` is called.  See how `YakFeedDelegate` is used for a hint.
	
In summary: the `YakCenter` has already been setup to save and fetch replies. Your task is to have the appropriate view controller/s make use of these functions, similar to how we implemented saving and fetching Yaks.

Send your completed work back to us as a pull request
