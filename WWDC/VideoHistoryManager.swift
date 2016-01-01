//
//  VideoHistoryManager.swift
//  WWDC
//
//  Created by hewig on 12/30/15.
//  Copyright © 2015 Bronron Apps. All rights reserved.
//

import Foundation
import UIKit

let kVideoHistoryKey = "kVideoHistoryKey"

@objc public class VideoHistory: NSObject {
    var title = ""
    var videoDescription = ""
    var imageUrl: String
    var videoUrl: NSURL
    var videoId: Int
    var played: Double = 0.0
    
    init(videoId: Int, title: String, imageUrl: String, videoUrl: NSURL) {
        self.videoId = videoId
        self.title = title
        self.imageUrl = imageUrl
        self.videoUrl = videoUrl
        
        super.init()
    }
    
    init(dictionary: NSDictionary) {
        self.videoId = dictionary["videoId"] as! Int
        self.videoUrl = dictionary["videoUrl"] as! NSURL
        self.title = dictionary["title"] as! String
        self.videoDescription = dictionary["description"] as! String
        self.played = dictionary["played"] as! Double
        self.imageUrl = dictionary["imageUrl"] as! String
        super.init()
    }
    
    public func toNSDictionary() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        dictionary["title"] = self.title
        dictionary["description"] = self.videoDescription
        dictionary["videoId"] = self.videoId
        dictionary["played"] = self.played
        dictionary["videoUrl"] = self.videoUrl
        dictionary["imageUrl"] = self.imageUrl
        return NSDictionary(dictionary: dictionary)
    }
}

@objc public class VideoHistoryManager: NSObject {
    static let sharedManager = VideoHistoryManager()
    static let defaults = NSUserDefaults(suiteName: kDefaultsKey)!
    static let kDefaultsKey = "group.in.fourplex.WWDCTV"
    
    var defaults: NSUserDefaults {
        get {
            return VideoHistoryManager.defaults
        }
    }
    
    public func addVideo(video: VideoHistory) {
        var history: [NSDictionary] = []
        if let oldHistory = self.defaults.arrayForKey(kVideoHistoryKey) as? [NSDictionary] {
            history += oldHistory
        }
        history = history.filter({ (history) -> Bool in
            if let videoId = history["videoId"] as? Int {
                if videoId == video.videoId {
                    return false
                }
            }
            return true
        })
        history.insert(video.toNSDictionary(), atIndex: 0)
        let ordered = NSOrderedSet(array: history as [NSDictionary])
        self.defaults.setObject(ordered.array, forKey: kVideoHistoryKey)
        self.defaults.synchronize()
    }
    
    public func updateVideo(video: VideoHistory) {
        
    }
    
    public func videoHistory() -> NSArray {
        if let history = self.defaults.arrayForKey(kVideoHistoryKey) {
            return NSArray(array: history)
        }
        return NSArray()
    }
}