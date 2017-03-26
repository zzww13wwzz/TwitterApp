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

@end

@implementation TwitterAPI


- (void)loadTweetWithIOSAccount:(ACAccount *)account
                     completion:(void (^)(NSError * error))completion
{
    _twitter = nil;
    if (account) {
        _twitter = [STTwitterAPI twitterAPIOSWithAccount:account delegate:nil];
    } else {
        _twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:CONSUMER_KEY
                                                 consumerSecret:CONSUMER_SECRET
                                                     oauthToken:[[NSUserDefaults standardUserDefaults] valueForKey:@"oauthToken"]
                                               oauthTokenSecret:[[NSUserDefaults standardUserDefaults] valueForKey:@"oauthTokenSecret"]];
        
        
    }
    [_twitter verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
        [_twitter getHomeTimelineSinceID:nil
                                   count:5
                            successBlock:^(NSArray *statuses) {
                                [[NSUserDefaults standardUserDefaults] setObject:userID forKey:@"userID"];
                                NSLog(@"-- statuses: %@", statuses);
                                for (NSDictionary * tweet in statuses) {
                                    NSDateFormatter * dateFormatter = [NSDateFormatter new];
                                    dateFormatter.dateFormat = @"EEE MMM dd HH:mm:ss ZZZ yyyy";
//                                    @"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"
//                                    @"EEE, dd MMM yyyy HH:mm:ss ZZZ"]
//                                    Fri Mar 24 14:45:39 +0000 2017
                                    NSTimeZone * timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
                                    dateFormatter.timeZone = timeZone;
//                                    NSLocale *locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
//                                    dateFormatter.locale = locale;
                                    for (id key in tweet) {
                                        NSLog(@"key: %@, value: %@ \n", key, [tweet objectForKey:key]);
                                    }
                                    NSLog(@"block = %@", tweet);
                                    [History historyWithNickName:tweet[@"user"][@"screen_name"]
                                                        userName:tweet[@"user"][@"name"]
                                                     userIconUrl:tweet[@"user"][@"profile_image_url"]
                                                     textMessage:tweet[@"text"]
                                                       createdAt:[dateFormatter dateFromString:tweet[@"created_at"]]];
//                                    if(sinceID) md[@"since_id"] = sinceID;
//                                    if(count) md[@"count"] = count;
                                    
                                    
                                }
                                
                                //self.statuses = statuses;
                                
                                //[self.tableView reloadData];
                                PERFORM_BLOCK(completion, nil);
                            } errorBlock:^(NSError *error) {
                                
                               // [self showAlertWithString:nil withError:error];
                                NSLog(@"%@", error);
                                //self.getTimelineStatusLabel.text = [error localizedDescription];
                                PERFORM_BLOCK(completion, error);
                            }];
        //_loginStatusLabel.text = [NSString stringWithFormat:@"@%@ (%@)", username, userID];
        
    } errorBlock:^(NSError *error) {
        PERFORM_BLOCK(completion, error);
        //[self showAlertWithString:nil withError:error];
        // _loginStatusLabel.text = [error localizedDescription];
    }];
    
}

@end
