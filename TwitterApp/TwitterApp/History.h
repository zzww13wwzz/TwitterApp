//
//  History.h
//  TwitterApp
//
//  Created by Viktoriia Vovk on 3/26/17.
//  Copyright © 2017 Viktoriia Vovk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface History : NSManagedObject

+ (History *) historyWithNickName:(NSString *)nickName
                         userName:(NSString *)userName
                      userIconUrl:(NSString *)userIconUrl
                      textMessage:(NSString *)textMessage
                     retweetCount:(NSString *)retweetCount
                    favoriteCount:(NSString *)favoriteCount
                         mediaUrls:(NSArray *)mediaUrls
                          isPhoto:(NSNumber *)isPhoto
                        createdAt:(NSDate *)createdAt;

@end

NS_ASSUME_NONNULL_END

#import "History+CoreDataProperties.h"
