//
//  VideoDetailViewController.h
//  WWDC
//
//  Created by Aaron Stephenson on 17/11/2015.
//  Copyright © 2015 Bronron Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoDetailViewController : UIViewController
@property (nonatomic, weak) IBOutlet UIButton *playButton;
- (void)setupVideoDictionaryObject:(NSDictionary *)videoDictionary;
@end
