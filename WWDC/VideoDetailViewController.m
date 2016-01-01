//
//  VideoDetailViewController.m
//  WWDC
//
//  Created by Aaron Stephenson on 17/11/2015.
//  Copyright © 2015 Bronron Apps. All rights reserved.
//

#import "VideoDetailViewController.h"
#import "Header.h"
#import "AVPlayer+Snapshot.h"
#import "WWDC-Swift.h"

@import AVKit;

@interface VideoDetailViewController ()
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *platformLabel;
@property (nonatomic, weak) IBOutlet UILabel *sessionIDLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) NSDictionary *videoDictionary;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItemVideoOutput *output;
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
    NSDictionary *attributes = @{(NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};
    self.output = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:attributes];
    vc.player = self.player;
    [vc.player.currentItem addOutput:self.output];
    [self presentViewController:vc animated:true completion:^{
        [self.player play];
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (object == self.player && [keyPath isEqualToString:@"rate"]) {
        if (self.player.rate == 0.0) {
            VideoHistory *history = [self createVideoHistory];
            [[VideoHistoryManager sharedManager] addVideo:history];
        }
    }
}

- (UIImage *)snapshotCurrentImageInOutput
{
    CVPixelBufferRef pixelBuffer = [self.output copyPixelBufferForItemTime:self.player.currentTime
                                                        itemTimeForDisplay:nil];
    if (!pixelBuffer) {
        return nil;
    }
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGRect rect = CGRectMake(0, 0, CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer));
    CGImageRef videoImage = [context createCGImage:ciImage
                                          fromRect:rect];
    UIImage *uiImage = [UIImage imageWithCGImage:videoImage];
    if (videoImage) {
        CGImageRelease(videoImage);
    }
    return uiImage;
}

- (VideoHistory *)createVideoHistory
{
    NSNumber *orderId = self.videoDictionary[@"order_id"];
    UIImage *image = [self snapshotCurrentImageInOutput];
    NSString *imageUrl = [NSString stringWithFormat:@"%@.jpg", orderId];
    if (image) {
        NSData *data = UIImageJPEGRepresentation(image, 1.0);
        
        NSURL *containerUrl = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:[VideoHistoryManager kDefaultsKey]];
        containerUrl = [containerUrl URLByAppendingPathComponent:imageUrl];
        NSError *error = nil;
        if([data writeToURL:containerUrl options:NSDataWritingAtomic error:&error]) {
            NSLog(@"save to %@", containerUrl);
        } else {
            NSLog(@"save failed %@", error.description);
        }
    }
    VideoHistory *history = [[VideoHistory alloc] initWithVideoId:[orderId longLongValue]
                                                            title:self.videoDictionary[@"title"]
                                                         imageUrl:imageUrl
                                                         videoUrl:self.videoDictionary[@"video_url"]];
    CMTime time = self.player.currentItem.currentTime;
    history.played = time.value / time.timescale;
    history.videoDescription = self.videoDictionary[@"description"];
    return history;
}

@end
