//
//  TwitterAPI.h
//  TwitterApp
//
//  Created by Viktoriia Vovk on 3/26/17.
//  Copyright © 2017 Viktoriia Vovk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import "STTwitter.h"
#import <AFNetworking/AFNetworking.h>

@interface TwitterAPI : NSObject

+ (BOOL)isInternetAvailable;

+ (void)setupReachability;

- (void)loadTweetWithIOSAccount:(ACAccount *)account
                 completion:(void (^)(NSError * error))completion;

- (void) postTweetWithMessage:(NSString *)message
                   completion:(void (^)(NSError * error))completion;
@end
