//
//  VideoPlayManager.swift
//  WWDC
//
//  Created by hewig on 1/3/16.
//  Copyright © 2016 Bronron Apps. All rights reserved.
//

import UIKit
import AVKit

@objc public class VideoPlayer: NSObject {
    
    static let kRateKey = "rate"
    public weak var parentViewController: UIViewController?
    public var videoHistory: VideoHistory?
    
    private var videoUrl: NSURL
    private var playViewController: AVPlayerViewController
    private var player: AVPlayer {
        willSet {
            self.player.removeObserver(self, forKeyPath: VideoPlayer.kRateKey)
        }
        didSet {
            self.player.addObserver(self, forKeyPath: VideoPlayer.kRateKey, options: .New, context: nil)
        }
    }
    private var output: AVPlayerItemVideoOutput

    init(url: NSURL, parentViewController: UIViewController?) {
        self.videoUrl = url
        self.playViewController = AVPlayerViewController()
        self.player = AVPlayer(URL: self.videoUrl)
        let attributes = [kCVPixelBufferPixelFormatTypeKey as String: NSNumber(unsignedInt: kCVPixelFormatType_32BGRA)]
        self.output = AVPlayerItemVideoOutput(pixelBufferAttributes: attributes)
        self.player.currentItem?.addOutput(self.output)
        self.parentViewController = parentViewController
        
        super.init()
    }
    
    deinit {
        self.player.removeObserver(self, forKeyPath: VideoPlayer.kRateKey)
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let player = object as? AVPlayer {
            if (player == self.player && keyPath! == VideoPlayer.kRateKey) {
                self.recordHistory()
            }
        }
    }
    
    public func play() {
        
        if let played = self.videoHistory?.played {
            if played.value > 0 && played.timescale > 0 {
                let alert = UIAlertController(title: "Continue Playing",
                                            message: "Last watched seconds \(played.value / Int64(played.timescale))",
                                     preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "YES", style: .Default, handler: { (_) -> Void in
                    // todo
                }))
                
                alert.addAction(UIAlertAction(title: "NO", style: .Cancel, handler: { (_) -> Void in
                    // todo
                }))
            }
        } else {
        
            self.parentViewController?.presentViewController(self.playViewController, animated: true, completion:
            { () -> Void in
                self.player.play()
            })
        }
    }
    
    public func snapshot() -> UIImage? {
        let pixelBuffer = self.output.copyPixelBufferForItemTime(self.player.currentTime(), itemTimeForDisplay: nil)
        if pixelBuffer == nil {
            return nil
        }
        let ciImage = CIImage(CVPixelBuffer: pixelBuffer!)
        let context = CIContext(options: nil)
        let rect = CGRectMake(0, 0, CGFloat(CVPixelBufferGetWidth(pixelBuffer!)),
                                    CGFloat(CVPixelBufferGetHeight(pixelBuffer!)))
        let imageRef = context.createCGImage(ciImage, fromRect: rect)
        let image = UIImage(CGImage: imageRef)
        
        //todo crop to fit top shelf
        
        return image
    }
    
    public func recordHistory() {
        if (self.videoHistory != nil) {
            let orderId = self.videoHistory?.videoId
            if let image = self.snapshot() {
                let data = UIImageJPEGRepresentation(image, 1.0)
                var path = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(VideoHistoryManager.kDefaultsKey)
                path = path?.URLByAppendingPathComponent("\(orderId).jpg")
                
                do {
                    try data?.writeToURL(path!, options: NSDataWritingOptions.AtomicWrite)
                } catch _ {
                    print("fail to save \(path?.lastPathComponent)")
                }
            }
            let time = self.player.currentTime()
            self.videoHistory?.played = time
            self.videoHistory?.imageUrl = "\(orderId).jpg";
            VideoHistoryManager.sharedManager.addVideo(self.videoHistory!)
        }
    }
}