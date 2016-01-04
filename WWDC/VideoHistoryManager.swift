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
        
        var existed: NSMutableDictionary?

        // filter out same id history
        history = history.filter({ (history) -> Bool in
            if let videoId = history["videoId"] as? Int {
                if videoId == video.videoId {
                    existed = NSMutableDictionary(dictionary: history)
                    return false
                }
            }
            return true
        })
        
        if existed == nil {
            history.insert(video.toNSDictionary(), atIndex: 0)
        } else {
            existed!["imageUrl"] = video.imageUrl
            existed!["played"] = video.played
        }
        
        let ordered = NSOrderedSet(array: history as [NSDictionary])
        self.defaults.setObject(ordered.array, forKey: kVideoHistoryKey)
        self.defaults.synchronize()
    }
    
    public func videoHistory() -> NSArray {
        if let history = self.defaults.arrayForKey(kVideoHistoryKey) {
            return NSArray(array: history)
        }
        return NSArray()
    }
    
    // todo
    public func videoHistory(videoId: Int) -> VideoHistory? {
        return nil
    }
}