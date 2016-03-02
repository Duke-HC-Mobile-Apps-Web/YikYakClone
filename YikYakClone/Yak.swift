//
//  Yak.swift
//  YikYakClone
//
//  Created by Jesse Hu on 2/10/16.
//  Copyright © 2016 Jesse Hu. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class Yak: NSObject {
    var text: String
    var timestamp: NSDate?
    var replies: [Reply]
    var netVoteCount: Int
    var location: CLLocationCoordinate2D?
    var snapshot: FDataSnapshot?
    
    init(text: String, timestamp: NSDate?, location: CLLocationCoordinate2D?) {
        self.text = text
        self.timestamp = timestamp
        self.replies = [Reply]()
        self.netVoteCount = 0
        self.location = location
    }
    
    //we need an initializer for turning a dictionary from firebase into an object
    init(dictionary: Dictionary<String, AnyObject>, snapshot: FDataSnapshot){
        self.text = dictionary["text"] as! String
        let timeInterval = dictionary["timestamp"] as? Double
        if (timeInterval != nil){
            self.timestamp = NSDate(timeIntervalSince1970:-1 * timeInterval!)
        }
        self.replies = [Reply]()
        self.netVoteCount = 0
        self.snapshot = snapshot
    }
    
    func toDictionary() -> Dictionary<String, AnyObject> {
        return [
            "text": text,
            "timestamp": -1 * timestamp!.timeIntervalSince1970,
            "votes": netVoteCount
        ]
    }
    
    //MARK: helper
    func timestampToReadable() -> String{
        if let date = self.timestamp {
            let calendar = NSCalendar.currentCalendar()
            let components = calendar.components([.Year, .WeekOfYear, .Day, .Hour, .Minute, .Second], fromDate: date, toDate: NSDate(), options: [])
            if components.year > 0 {
                return "\(components.year)y"
            } else if components.weekOfYear > 0 {
                return "\(components.weekOfYear)w"
            } else if components.day > 0 {
                return "\(components.day)d"
            } else if components.hour > 0 {
                return "\(components.hour)h"
            } else if components.minute > 0 {
                return "\(components.minute)m"
            } else if components.second > 0 {
                return "\(components.second)s"
            } else {
                return "Just now"
            }
        } else {
            return ""
        }
    }
}
