//
//  VideoHistory.swift
//  WWDC
//
//  Created by hewig on 1/3/16.
//  Copyright © 2016 Bronron Apps. All rights reserved.
//

import Foundation
import AVFoundation

@objc public class VideoHistory: NSObject {
    public var title = ""
    public var sessionId = ""
    public var videoDescription = ""
    public var imageUrl: String
    public var videoUrl: NSURL
    public var videoId: Int
    public var played: CMTime
    
    init(videoId: Int, title: String, imageUrl: String, videoUrl: NSURL) {
        self.videoId = videoId
        self.title = title
        self.imageUrl = imageUrl
        self.videoUrl = videoUrl
        self.played = CMTimeMake(0, 1)
        super.init()
    }
    
    init(dictionary: NSDictionary) {
        self.videoId = dictionary["videoId"] as! Int
        self.videoUrl = dictionary["videoUrl"] as! NSURL
        self.title = dictionary["title"] as! String
        self.videoDescription = dictionary["description"] as! String
        if let d = dictionary["played"] as! CFDictionary? {
            self.played = CMTimeMakeFromDictionary(d)
        } else {
            self.played = CMTimeMake(0, 1)
        }
        
        self.imageUrl = dictionary["imageUrl"] as! String
        self.sessionId = dictionary["sessionId"] as! String
        super.init()
    }
    
    public func toNSDictionary() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        dictionary["title"] = self.title
        dictionary["description"] = self.videoDescription
        dictionary["videoId"] = self.videoId
        dictionary["played"] = CMTimeCopyAsDictionary(self.played, nil)
        dictionary["videoUrl"] = self.videoUrl
        dictionary["imageUrl"] = self.imageUrl
        dictionary["sessionId"] = self.sessionId
        return NSDictionary(dictionary: dictionary)
    }
}