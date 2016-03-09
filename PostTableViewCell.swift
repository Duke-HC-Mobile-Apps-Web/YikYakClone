//
//  PostTableViewCell.swift
//  YikYakClone
//
//  Created by Jesse Hu on 2/10/16.
//  Copyright © 2016 Jesse Hu. All rights reserved.
//

import UIKit

protocol PostTableViewCellDelegate {
    func didUpvoteCellAtIndexPath(indexPath: NSIndexPath)
    func didDownvoteCellAtIndexPath(indexPath: NSIndexPath)
}

class PostTableViewCell: UITableViewCell {

    @IBOutlet var textView: UITextView! {
        didSet {
            textView.textContainer.lineFragmentPadding = 0
            textView.textContainerInset = UIEdgeInsetsZero
        }
    }
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var repliesLabel: UILabel!
    @IBOutlet var voteCountLabel: UILabel!
    
    var delegate: PostTableViewCellDelegate?
    var indexPath: NSIndexPath?
    
    @IBAction func upvoteButtonPressed(sender: UIButton) {
        if let indexPath = indexPath, delegate = delegate {
            delegate.didUpvoteCellAtIndexPath(indexPath)
        }
    }
    @IBAction func downvoteButtonPressed(sender: UIButton) {
        if let indexPath = indexPath, delegate = delegate {
            delegate.didDownvoteCellAtIndexPath(indexPath)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
