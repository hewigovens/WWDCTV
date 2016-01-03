//
//  ServiceProvider.swift
//  TopShelf
//
//  Created by hewig on 12/30/15.
//  Copyright © 2015 Bronron Apps. All rights reserved.
//

import Foundation
import TVServices

public enum SectionIdentifier: String {
    case History
    case Favorite
}

class ServiceProvider: NSObject, TVTopShelfProvider {

    override init() {
        super.init()
    }

    // MARK: - TVTopShelfProvider protocol

    var topShelfStyle: TVTopShelfContentStyle {
        // Return desired Top Shelf style.
        return .Sectioned
    }

    var topShelfItems: [TVContentItem] {
        let history = VideoHistoryManager.sharedManager.videoHistory()
        print("video history count = \(history.count)")
        
        let sectionId = TVContentIdentifier(identifier: SectionIdentifier.History.rawValue, container: nil)
        let sectionItem = TVContentItem(contentIdentifier: sectionId!)!
        sectionItem.title = SectionIdentifier.History.rawValue
        
        let contentItems: [TVContentItem] = history.map { (video) -> TVContentItem in
            guard let dict = video as? NSDictionary else {
                fatalError("cast video history")
            }
            let url = dict["videoUrl"] as! String
            let identifier = TVContentIdentifier(identifier: url, container: nil)
            guard let item = TVContentItem(contentIdentifier: identifier!) else {
                fatalError("create conten item fail")
            }
            item.title = "\(dict["sessionId"] as? String) \(dict["title"] as? String)"
            item.displayURL = self.displayUrl(dict)
            item.playURL = NSURL(string: url)
            item.imageShape = .ExtraWide
            if let imageUrl = dict["imageUrl"] as? String {
                if imageUrl.hasPrefix("http") {
                    item.imageURL = NSURL(string: imageUrl)
                } else {
                    let url = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(VideoHistoryManager.kDefaultsKey)
                    item.imageURL = url?.URLByAppendingPathComponent(imageUrl)
                }
            }
            
            return item
        }
        
        sectionItem.topShelfItems = contentItems
        return [sectionItem]
    }
    
    private func displayUrl(history: NSDictionary) -> NSURL {
        let components = NSURLComponents()
        components.scheme = "wwdctv"
        components.path = "history"
        var queries: [NSURLQueryItem] = []
        queries.append(NSURLQueryItem(name: "order_id", value: "\(history["videoId"] as? Int)"))
        queries.append(NSURLQueryItem(name: "video_url", value: history["videoUrl"] as? String))
        queries.append(NSURLQueryItem(name: "played", value: "\(history["played"] as? Int)"))
        components.queryItems = queries
        
        return components.URL!
    }
}

