//
//  TwitterAPI.m
//  TwitterApp
//
//  Created by Viktoriia Vovk on 3/26/17.
//  Copyright © 2017 Viktoriia Vovk. All rights reserved.
//

#import "TwitterAPI.h"
#import "History.h"

@interface TwitterAPI ()

@property (nonatomic, strong) STTwitterAPI *twitter;
@property (nonatomic, strong) ACAccount *savedAccount;
@end

@implementation TwitterAPI

- (ACAccount *)savedAccount {
    _savedAccount = nil;
    NSString * accountName =[[NSUserDefaults standardUserDefaults] objectForKey:@"account.username"];
    if (accountName) {
        ACAccountStore * accountStore = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        NSArray *iOSAccounts = [accountStore accountsWithAccountType:accountType];
        if (iOSAccounts.count > 0) {
            for(ACAccount *acc in iOSAccounts) {
                if ([acc.username isEqualToString:accountName]) {
                    _savedAccount = acc;
                }
            }
        }
    }
    return _savedAccount;
}

- (void) postTweetWithMessage:(NSString *)message
        completion:(void (^)(NSError * error))completion
{
    if (_savedAccount) {
        _twitter = [STTwitterAPI twitterAPIOSWithAccount:_savedAccount delegate:nil];
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
                             NSDateFormatter * dateFormatter = [NSDateFormatter new];
                             dateFormatter.dateFormat = @"EEE MMM dd HH:mm:ss ZZZ yyyy";
                             NSTimeZone * timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
                             dateFormatter.timeZone = timeZone;
                             
                             for (id key in status) {
                                 NSLog(@"key: %@, value: %@ \n", key, [status objectForKey:key]);
                             }
                             
                             [History historyWithNickName:status[@"user"][@"screen_name"]
                                                 userName:status[@"user"][@"name"]
                                              userIconUrl:status[@"user"][@"profile_image_url_https"]
                                              textMessage:status[@"text"]
                                                createdAt:[dateFormatter dateFromString:status[@"created_at"]]];
                             
                             NSLog(@"-- status2: %@", status);
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
    
    
    
    
    //    self.twitter = [STTwitterAPI twitterAPIOSWithFirstAccount];
    
    //    [_twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
    
    
    //    }];
    
    //    [twitter postStatusUpdate:@"test"
    //            inReplyToStatusID:nil
    //                     latitude:nil
    //                    longitude:nil
    //                      placeID:nil
    //           displayCoordinates:nil
    //                     trimUser:nil
    //                 successBlock:^(NSDictionary *status) {
    //                     // ...
    //                 } errorBlock:^(NSError *error) {
    //                     // ...
    //                 }];
}

- (void)pullToRefreash {
    _twitter = nil;
    //    _twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:<#(NSString *)#> consumerSecret:<#(NSString *)#> oauthToken:<#(NSString *)#> oauthTokenSecret:<#(NSString *)#>]
    
    /*
     At this point, the user can use the API and you can read his access tokens with:
     
     _twitter.oauthAccessToken;
     _twitter.oauthAccessTokenSecret;
     
     You can store these tokens (in user default, or in keychain) so that the user doesn't need to authenticate again on next launches.
     
     Next time, just instanciate STTwitter with the class method:
     
     +[STTwitterAPI twitterAPIWithOAuthConsumerKey:consumerSecret:oauthToken:oauthTokenSecret:]
     
     Don't forget to call the -[STTwitter verifyCredentialsWithSuccessBlock:errorBlock:] after that.
     */
    
}

- (void)loadTweetWithIOSAccount:(ACAccount *)account
                     completion:(void (^)(NSError * error))completion
{
    _twitter = nil;
    
    if (account) {
        _twitter = [STTwitterAPI twitterAPIOSWithAccount:account delegate:nil];
    } else if (_savedAccount){
        _twitter = [STTwitterAPI twitterAPIOSWithAccount:_savedAccount delegate:nil];
    } else {
        _twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:CONSUMER_KEY
                                                 consumerSecret:CONSUMER_SECRET
                                                     oauthToken:[[NSUserDefaults standardUserDefaults] valueForKey:@"oauthToken"]
                                               oauthTokenSecret:[[NSUserDefaults standardUserDefaults] valueForKey:@"oauthTokenSecret"]];
    }
    
    [_twitter verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
        [_twitter getHomeTimelineSinceID:nil
                                   count:50
                            successBlock:^(NSArray *statuses) {
                                [[NSUserDefaults standardUserDefaults] setObject:userID forKey:@"userID"];
                                
                                //                                NSLog(@"-- statuses: %@", statuses);
                                for (NSDictionary * tweet in statuses) {
                                    NSDateFormatter * dateFormatter = [NSDateFormatter new];
                                    dateFormatter.dateFormat = @"EEE MMM dd HH:mm:ss ZZZ yyyy";
                                    NSTimeZone * timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
                                    dateFormatter.timeZone = timeZone;
                                    
                                    for (id key in tweet) {
                                        NSLog(@"key: %@, value: %@ \n", key, [tweet objectForKey:key]);
                                    }
                                    
                                    [History historyWithNickName:tweet[@"user"][@"screen_name"]
                                                        userName:tweet[@"user"][@"name"]
                                                     userIconUrl:tweet[@"user"][@"profile_image_url_https"]
                                                     textMessage:tweet[@"text"]
                                                       createdAt:[dateFormatter dateFromString:tweet[@"created_at"]]];
                                    
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

@end
