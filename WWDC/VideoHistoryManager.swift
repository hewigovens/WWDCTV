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
let kDefaultsKey = "group.in.fourplex.WWDCTV"

@objc public class VideoHistory: NSObject {
    var title = ""
    var videoDescription = ""
    var cover: UIImage?
    var videoUrl: NSURL
    var videoId: Int
    var played: Int = 0
    
    init(videoId: Int, title: String, cover: UIImage?, videoUrl: NSURL) {
        self.videoId = videoId
        self.title = title
        self.cover = cover
        self.videoUrl = videoUrl
        
        super.init()
    }
}

@objc public class VideoHistoryManager: NSObject {
    static let sharedManager = VideoHistoryManager()
    static let defaults = NSUserDefaults(suiteName: kDefaultsKey)!
    
    var defaults: NSUserDefaults {
        get {
            return VideoHistoryManager.defaults
        }
    }
    
    public func addVideo(video: VideoHistory) {
        var history: [VideoHistory] = []
        if let oldHistory = self.defaults.arrayForKey(kVideoHistoryKey) as? [VideoHistory] {
            history += oldHistory
        }
        history.insert(video, atIndex: 0)
        let ordered = NSOrderedSet(array: history as [AnyObject])
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