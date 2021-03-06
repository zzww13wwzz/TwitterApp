//
//  History.m
//  TwitterApp
//
//  Created by Viktoriia Vovk on 3/26/17.
//  Copyright © 2017 Viktoriia Vovk. All rights reserved.
//

#import "History.h"

@implementation History
+ (History *) historyWithNickName:(NSString *)nickName
                         userName:(NSString *)userName
                      userIconUrl:(NSString *)userIconUrl
                      textMessage:(NSString *)textMessage
                     retweetCount:(NSString *)retweetCount
                    favoriteCount:(NSString *)favoriteCount
                         mediaUrls:(NSArray *)mediaUrls
                          isPhoto:(NSNumber *)isPhoto
                        createdAt:(NSDate *)createdAt
{
    History * history = [History MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"textMessage == %@", textMessage]];
    
    if (!history) {
        history = [History MR_createEntity];
    }
    history.nickName = nickName;
    if (userIconUrl) {
        history.userIconUrl = userIconUrl;
    }
    
    history.createdAt = createdAt;
    history.userName = userName;
    history.textMessage = textMessage;
    history.retweetCount = retweetCount;
    history.favoriteCount = favoriteCount;
    history.isPhoto = isPhoto;
    history.mediaUrls = mediaUrls;
    return history;
}

@end
