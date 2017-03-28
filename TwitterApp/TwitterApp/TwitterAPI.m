//
//  TwitterAPI.m
//  TwitterApp
//
//  Created by Viktoriia Vovk on 3/26/17.
//  Copyright © 2017 Viktoriia Vovk. All rights reserved.
//

#import "TwitterAPI.h"
#import "History.h"
#import "Reachability.h"

@interface TwitterAPI ()

@property (nonatomic, strong) STTwitterAPI *twitter;

@end

@implementation TwitterAPI

+ (BOOL) isInternetAvailable
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus != NotReachable) {
        return YES;
    }
    else {
        return NO;
    }
}

+ (void) setupReachability
{
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (![[self class] isInternetAvailable]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_internet_connection_lost
                                                                object:nil];
        }
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}


- (ACAccount *)savedAccount
{
    ACAccount * account = nil;
    NSString * accountName =[[NSUserDefaults standardUserDefaults] objectForKey:@"account.username"];
    if (accountName) {
        ACAccountStore * accountStore = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        NSArray *iOSAccounts = [accountStore accountsWithAccountType:accountType];
        if (iOSAccounts.count > 0) {
            for(ACAccount *acc in iOSAccounts) {
                if ([acc.username isEqualToString:accountName]) {
                    account = acc;
                }
            }
        }
    }
    return account;
}

- (void) postTweetWithMessage:(NSString *)message
                   completion:(void (^)(NSError * error))completion
{
    if ([self savedAccount]) {
        _twitter = [STTwitterAPI twitterAPIOSWithAccount:[self savedAccount] delegate:nil];
    } else {
        _twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:CONSUMER_KEY
                                                 consumerSecret:CONSUMER_SECRET
                                                     oauthToken:[[NSUserDefaults standardUserDefaults] valueForKey:@"oauthToken"]
                                               oauthTokenSecret:[[NSUserDefaults standardUserDefaults] valueForKey:@"oauthTokenSecret"]];
    }
    [_twitter verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
        [ _twitter postStatusesUpdate:message
                    inReplyToStatusID:nil
                             latitude:nil
                            longitude:nil
                              placeID:nil
                   displayCoordinates:nil
                             trimUser:nil
            autoPopulateReplyMetadata:nil
           excludeReplyUserIDsStrings:nil
                  attachmentURLString:nil
                 useExtendedTweetMode:nil
                         successBlock:^(NSDictionary *status) {
                             [self saveData: status];
                             SAVE_DB_LOCALY;
                             PERFORM_BLOCK(completion, nil);
                             
                         } errorBlock:^(NSError *error) {
                             NSLog(@"-- error2: %@", error);
                             PERFORM_BLOCK(completion, error);
                         }];
        
    } errorBlock:^(NSError *error) {
        NSLog(@"-- error0: %@", error);
        PERFORM_BLOCK(completion, error);
    }];
}

- (void)loadTweetWithIOSAccount:(ACAccount *)account
                     completion:(void (^)(NSError * error))completion
{
    _twitter = nil;
    
    if (account) {
        _twitter = [STTwitterAPI twitterAPIOSWithAccount:account delegate:nil];
        [[NSUserDefaults standardUserDefaults] setObject:account.username forKey:@"account.username"];
        
    } else {
        if ([self savedAccount]){
            _twitter = [STTwitterAPI twitterAPIOSWithAccount:[self savedAccount] delegate:nil];
        } else {
            _twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:CONSUMER_KEY
                                                     consumerSecret:CONSUMER_SECRET
                                                         oauthToken:[[NSUserDefaults standardUserDefaults] valueForKey:@"oauthToken"]
                                                   oauthTokenSecret:[[NSUserDefaults standardUserDefaults] valueForKey:@"oauthTokenSecret"]];
        }
    }
    [_twitter verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
        [_twitter getHomeTimelineSinceID:nil
                                   count:50
                            successBlock:^(NSArray *statuses) {
                                [[NSUserDefaults standardUserDefaults] setObject:userID forKey:@"userID"];
                                for (NSDictionary * tweet in statuses) {
                                    [self saveData: tweet];
                                }
                                SAVE_DB_LOCALY;
                                PERFORM_BLOCK(completion, nil);
                            } errorBlock:^(NSError *error) {
                                NSLog(@"%@", error);
                                PERFORM_BLOCK(completion, error);
                            }];
    } errorBlock:^(NSError *error) {
        PERFORM_BLOCK(completion, error);
    }];
    
}

- (void)saveData:(NSDictionary *)tweet
{
    NSDateFormatter * dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"EEE MMM dd HH:mm:ss ZZZ yyyy";
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    
    BOOL isPhoto = NO;
    NSMutableArray * mediaUrls = [NSMutableArray new];
    
    if (tweet[@"extended_entities"]) {
        if (tweet[@"extended_entities"][@"media"]) {
            for (NSDictionary *media in tweet[@"extended_entities"][@"media"]) {
                
                isPhoto = [media[@"type"] isEqualToString:@"photo"];
                if (isPhoto) {
                    NSString * url = media[@"media_url_https"];
                    [mediaUrls addObject:url];
                } else {
                    NSArray * variants = media[@"video_info"][@"variants"];
                    for (NSArray * var in variants) {
                        if ([[var valueForKey:@"content_type"] isEqualToString:@"video/mp4"]) {
                            [mediaUrls addObject:[var valueForKey:@"url"]];
                        }
                    }
                }
            }
        }
    }
    [History historyWithNickName:tweet[@"user"][@"screen_name"]
                        userName:tweet[@"user"][@"name"]
                     userIconUrl:tweet[@"user"][@"profile_image_url_https"]
                     textMessage:tweet[@"text"]
                    retweetCount:[tweet[@"retweet_count"] stringValue]
                   favoriteCount:[tweet[@"favorite_count"] stringValue]
                       mediaUrls:mediaUrls
                         isPhoto:[NSNumber numberWithBool:isPhoto]
                       createdAt:[dateFormatter dateFromString:tweet[@"created_at"]]];
    
}

@end
