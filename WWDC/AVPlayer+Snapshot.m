//
//  AVPlayer+Snapshot.m
//  WWDC
//
//  Created by hewig on 1/1/16.
//  Copyright © 2016 Bronron Apps. All rights reserved.
//

@import UIKit;
#import "AVPlayer+Snapshot.h"

@implementation AVPlayer (Snapshot)

- (UIImage *)snapshotCurrentTimeImage
{
    if (self.status != AVPlayerStatusReadyToPlay) {
        return nil;
    }
    NSError *error = nil;
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:[self.currentItem asset]];
    generator.appliesPreferredTrackTransform = YES;
    CGImageRef imageRef = [generator copyCGImageAtTime:self.currentTime actualTime:nil error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    if (imageRef) {
        CGImageRelease(imageRef);
    }
    return image;
}

@end
