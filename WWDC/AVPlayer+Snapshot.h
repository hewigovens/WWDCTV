//
//  AVPlayer+Snapshot.h
//  WWDC
//
//  Created by hewig on 1/1/16.
//  Copyright © 2016 Bronron Apps. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface AVPlayer (Snapshot)
- (UIImage *)snapshotCurrentTimeImage;
@end
