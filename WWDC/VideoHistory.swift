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
        self.played = CMTime()
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