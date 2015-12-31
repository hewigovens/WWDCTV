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
        print("get history = \(history.count)")
        
        let sectionId = TVContentIdentifier(identifier: SectionIdentifier.History.rawValue, container: nil)
        let sectionItem = TVContentItem(contentIdentifier: sectionId!)!
        sectionItem.title = SectionIdentifier.History.rawValue
        
        let contentItems: [TVContentItem] = history.map { (video) -> TVContentItem in
            guard let dict = video as? NSDictionary else {
                fatalError("cast video history")
            }
            let url = dict["video_url"] as! String
            let identifier = TVContentIdentifier(identifier: url, container: nil)
            guard let item = TVContentItem(contentIdentifier: identifier!) else {
                fatalError("create conten item fail")
            }
            item.title = dict["title"] as? String
            item.playURL = NSURL(string: url)
            item.imageShape = .ExtraWide
            if let imageUrl = NSBundle.mainBundle().URLForResource("Iceland 1.jpg", withExtension: nil) {
                item.imageURL = imageUrl
            }
            
            return item
        }
        
        sectionItem.topShelfItems = contentItems
        return [sectionItem]
    }

}

