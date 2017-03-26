//
//  AppDelegate.h
//  TwitterApp
//
//  Created by Viktoriia Vovk on 3/22/17.
//  Copyright © 2017 Viktoriia Vovk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong) NSPersistentContainer *persistentContainer;

@property (nonatomic) MBProgressHUD * mbprogressHUD;

- (void) showMBProgressHUDWithTitle:(NSString *)title
                           subTitle:(NSString *)subtitle
                               view:(UIView *)view;

- (void) saveDB;
- (void) cleanAndResetupDB;


//- (void)saveContext;


@end

