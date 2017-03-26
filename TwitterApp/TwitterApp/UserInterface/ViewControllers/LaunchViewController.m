//
//  LaunchViewController.m
//  TwitterApp
//
//  Created by Viktoriia Vovk on 3/22/17.
//  Copyright © 2017 Viktoriia Vovk. All rights reserved.
//

#import "LaunchViewController.h"

@interface LaunchViewController ()

@end

@implementation LaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupUser];
    
    
    
  //  [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"LoginVC"]
    //                                             animated:NO];
//    [AnalyticsManager setScreenName:@"Launch"];
//    
//    if ([User MR_findAll].count == 0) {
//        [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"LoginVC"]
//                           animated:NO
//                         completion:nil];
//    }
//    else {
//        [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"FeedVC"]
//                                             animated:NO];
//        
//        [ApplicationDelegate registerPushNotifications];
//    }
}

- (void)setupUser {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"userID"];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userID"]) {
        NSLog(@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"]);
        [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"FeedVC"]
                                             animated:NO];
        
    } else {
        [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"LoginVC"]
                           animated:NO
                         completion:nil];
        
        
    }
}
@end
