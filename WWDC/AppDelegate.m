//
//  AppDelegate.m
//  WWDC
//
//  Created by Aaron Stephenson on 17/11/2015.
//  Copyright © 2015 Bronron Apps. All rights reserved.
//

#import "AppDelegate.h"
#import "Header.h"
#import "VideoTableViewController.h"

@import AVKit;

@interface AppDelegate ()
@property (nonatomic, strong) UITabBarController *tabBarController;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSArray *videoArray = [self readJSONFile];
    
    // Override point for customization after application launch.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NSMutableArray *conferenceViewArray = [NSMutableArray new];
    
    //Setup each tabBarItem. Note that there is a limit of 5 tabbar items.
    for (NSString *conferenceID in videoArray)
    {
        if ([conferenceViewArray count] >= 5) break;

        UISplitViewController *splitViewController = [storyboard instantiateViewControllerWithIdentifier:@"SplitViewController"];
        splitViewController.preferredPrimaryColumnWidthFraction = 0.43;
        splitViewController.tabBarItem.title = conferenceID;
        UINavigationController *navController = [splitViewController.viewControllers firstObject];
        VideoTableViewController *vc = (VideoTableViewController *)[navController.viewControllers firstObject];
        vc.conference_id = conferenceID;
        [conferenceViewArray addObject:splitViewController];
    }

    //Setup the tabBarController
    self.tabBarController = [UITabBarController new];
    self.tabBarController.viewControllers = conferenceViewArray;
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (NSArray *)readJSONFile
{
    //Get JSON
    NSMutableArray *videoArray = [NSMutableArray new];
    NSError *error = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"videos" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *allVideos = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    //Sorts the conferences by order_id this has been onfigured to ensure the newer conferences appear first.
    NSSortDescriptor *brandDescriptor = [[NSSortDescriptor alloc] initWithKey:kOrderIDKey ascending:true];
    allVideos = [allVideos sortedArrayUsingDescriptors:@[brandDescriptor]];
    
    //Get the conference ids which are to be used for the tabBarController
    for (NSDictionary *videoDictionary in allVideos)
    {
        if (![videoArray containsObject:[videoDictionary objectForKey:kConferenceKey]])
        {
            [videoArray addObject:[videoDictionary objectForKey:kConferenceKey]];
        }
    }
    
    return [videoArray copy];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
{
    NSLog(@"open from top shelf %@", url);
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
    NSURLQueryItem *item = nil;
    for (NSURLQueryItem *query in components.queryItems) {
        if ([query.name isEqualToString:@"video_url"]) {
            item = query;
            break;
        }
    }
    if (item) {
        AVPlayerViewController *vc = [AVPlayerViewController new];
        vc.player = [AVPlayer playerWithURL:[NSURL URLWithString:item.value]];
        [self.tabBarController presentViewController:vc animated:YES completion:^{
            [vc.player play];
        }];
    }

    return YES;
}

@end
