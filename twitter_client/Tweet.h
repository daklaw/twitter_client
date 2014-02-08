//
//  Tweet.h
//  twitter_client
//
//  Created by David Law on 2/1/14.
//  Copyright (c) 2014 David Law. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RestObject.h"
#import "User.h"
#import <Parse/Parse.h>

@interface Tweet : RestObject

@property (nonatomic, strong, readonly) NSString *text;
@property (nonatomic, assign) bool favorited;
@property (nonatomic, assign) bool retweeted; // Retweeted by user
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, assign) NSInteger numFavorites;
@property (nonatomic, assign) NSInteger numRetweets;
@property (nonatomic, strong) NSString *tweetId;
@property (nonatomic, strong) NSString *retweetId;

- (id)initWithDictionary:(NSDictionary *)data;
+ (NSMutableArray *)tweetsWithArray:(NSArray *)array;
- (NSString *)timeSinceStr;
- (NSString *)name;
- (NSString *)screenName;
- (NSString *)retweetHeaderText;
- (NSString *)userId;
- (NSURL *)profileImageURL;
- (NSDate *)createdAt;
- (bool)isRetweet;
- (bool)canRetweet: (User *)user;
- (void)favorite:(UIButton *)button;
- (void)retweet: (UIButton *)button;


@end
