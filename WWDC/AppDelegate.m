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
#import "WWDC-Swift.h"

@interface AppDelegate ()
@property (nonatomic, strong) UITabBarController *tabBarController;
@property (nonatomic, strong) VideoPlayer *videoPlayer;
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
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    for (NSURLQueryItem *query in components.queryItems) {
        dict[query.name] = query.value;
    }
    
    if (dict[@"video_url"]) {
        NSURL *videoUrl = [NSURL URLWithString:dict[@"video_url"]];
        NSNumber *videoId = dict[@"order_id"];
        self.videoPlayer = [[VideoPlayer alloc] initWithUrl:videoUrl parentViewController:self.tabBarController];
        self.videoPlayer.videoHistory = [[VideoHistory alloc] initWithVideoId:[videoId integerValue]
                                                                        title:@""
                                                                     imageUrl:@""
                                                                     videoUrl:videoUrl];
        [self.videoPlayer play];
    }

    return YES;
}

@end
