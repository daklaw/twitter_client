//
//  Tweet.h
//  twitter_client
//
//  Created by David Law on 2/1/14.
//  Copyright (c) 2014 David Law. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RestObject.h"

@interface Tweet : RestObject

@property (nonatomic, strong, readonly) NSString *text;
@property (nonatomic, assign) bool favorited;
@property (nonatomic, assign) bool retweeted;
@property (nonatomic, strong) NSString *tweetId;
@property (nonatomic, strong) NSString *retweetId;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *screenName;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSURL *profileImageURL;
@property (nonatomic, assign) NSInteger numFavorites;
@property (nonatomic, assign) NSInteger numRetweets;

- (id)initWithDictionary:(NSDictionary *)data;
+ (NSMutableArray *)tweetsWithArray:(NSArray *)array;
- (NSString *)timeSinceStr;

@end
