//
//  VideoDetailViewController.m
//  WWDC
//
//  Created by Aaron Stephenson on 17/11/2015.
//  Copyright © 2015 Bronron Apps. All rights reserved.
//

#import "VideoDetailViewController.h"
#import "Header.h"
#import "WWDC-Swift.h"

@import AVKit;

@interface VideoDetailViewController ()
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *platformLabel;
@property (nonatomic, weak) IBOutlet UILabel *sessionIDLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) NSDictionary *videoDictionary;
@property (nonatomic, strong) AVPlayer *player;
@end

@implementation VideoDetailViewController

- (void)setPlayer:(AVPlayer *)player
{
    if (_player) {
        [_player removeObserver:self forKeyPath:@"rate"];
    }
    _player = player;
    [_player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // When setupVideoDictionary is called from the TableView Controller, this VC has not yet loaded from NIB.
    // This causes a bug where the labels show their default NIB contents.
    // Calling this method in viewDidLoad should cause the Labels to populate after loading from NIB.
    [self setupVideoDictionaryObject:self.videoDictionary];
}

//Setup detail labels
- (void)setupVideoDictionaryObject:(NSDictionary *)videoDictionary
{
    [UIView animateWithDuration:0.3 animations: ^{
        self.videoDictionary = videoDictionary;
        self.titleLabel.text = [self.videoDictionary objectForKey:kTitleKey];
        self.platformLabel.text = [self.videoDictionary objectForKey:kPlatformKey];
        self.sessionIDLabel.text = [self.videoDictionary objectForKey:kSessionIDKey];
        self.descriptionLabel.text = [self.videoDictionary objectForKey:kDescriptionKey];
        [self.view layoutIfNeeded];
    }];
}

//Plays the video on selecting the Play Video button
- (IBAction)playVideo:(id)sender
{
    AVPlayerViewController *vc = [AVPlayerViewController new];
    self.player = [AVPlayer playerWithURL:[NSURL URLWithString:self.videoDictionary[kVideoURLKey]]];
    vc.player = self.player;
    [self presentViewController:vc animated:true completion:^{
        [[VideoHistoryManager sharedManager] addVideo:[self createVideoHistory]];
        [self.player play];
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (object == self.player && [keyPath isEqualToString:@"rate"]) {
        if (self.player.rate == 0.0) {
            VideoHistory *history = [self createVideoHistory];
            [[VideoHistoryManager sharedManager] updateVideo:history];
        }
    }
}

- (UIImage *)snapshotImageWithCurrentFrame
{
    if (self.player.status != AVPlayerStatusReadyToPlay) {
        return nil;
    }
    return nil;
}

- (VideoHistory *)createVideoHistory
{
    UIImage *image = [self snapshotImageWithCurrentFrame];
    VideoHistory *history = [[VideoHistory alloc] initWithVideoId:[self.videoDictionary[@"orderId"] integerValue]
                                                            title:self.videoDictionary[@"title"]
                                                            cover:image
                                                         videoUrl:self.videoDictionary[@"videoUrl"]];
    history.videoDescription = self.videoDictionary[@"description"];
    return history;
}

@end
