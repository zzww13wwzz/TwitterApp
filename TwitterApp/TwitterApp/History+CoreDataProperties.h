//
//  History+CoreDataProperties.h
//  TwitterApp
//
//  Created by Viktoriia Vovk on 3/26/17.
//  Copyright © 2017 Viktoriia Vovk. All rights reserved.
//

#import "History.h"


NS_ASSUME_NONNULL_BEGIN

@interface History (CoreDataProperties)

@property (nullable, nonatomic, copy) NSDate *createdAt;
@property (nullable, nonatomic, copy) NSString *nickName;
@property (nullable, nonatomic, copy) NSString *textMessage;
@property (nullable, nonatomic, copy) NSString *userIconUrl;
@property (nullable, nonatomic, copy) NSString *userName;
@property (nullable, nonatomic, copy) NSString *retweetCount;
@property (nullable, nonatomic, copy) NSString *favoriteCount;
@property (nullable, nonatomic, copy) NSArray *mediaUrls;
@property (nullable, nonatomic, retain) NSNumber * isPhoto;

@end

NS_ASSUME_NONNULL_END
