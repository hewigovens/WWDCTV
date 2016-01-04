//
//  VideoHistory.swift
//  WWDC
//
//  Created by hewig on 1/3/16.
//  Copyright © 2016 Bronron Apps. All rights reserved.
//

import Foundation
import AVFoundation

@objc public class CMTimeWrapper: NSObject {
    public var flag: CMTimeFlags = CMTimeFlags(rawValue: 0)
    public var scale: Int32 = 0
    public var value: Int64 = 0
    public var epoch: Int64 = 0
    
    override init() {
        super.init()
    }
    init(value: Int64, scale: Int32, epoch: Int64, flag: CMTimeFlags){
        self.value = value
        self.scale = scale
        self.epoch = epoch
        self.flag = flag
        super.init()
    }
}

@objc public class VideoHistory: NSObject {
    public var title = ""
    public var sessionId = ""
    public var videoDescription = ""
    public var imageUrl: String
    public var videoUrl: NSURL
    public var videoId: Int
    public var played: CMTimeWrapper
    
    init(videoId: Int, title: String, imageUrl: String, videoUrl: NSURL) {
        self.videoId = videoId
        self.title = title
        self.imageUrl = imageUrl
        self.videoUrl = videoUrl
        self.played = CMTimeWrapper()
        super.init()
    }
    
    init(dictionary: NSDictionary) {
        self.videoId = dictionary["videoId"] as! Int
        self.videoUrl = dictionary["videoUrl"] as! NSURL
        self.title = dictionary["title"] as! String
        self.videoDescription = dictionary["description"] as! String
        self.played = dictionary["played"] as! CMTimeWrapper
        self.imageUrl = dictionary["imageUrl"] as! String
        self.sessionId = dictionary["sessionId"] as! String
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
        dictionary["sessionId"] = self.sessionId
        return NSDictionary(dictionary: dictionary)
    }
}