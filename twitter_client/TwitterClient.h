//
//  TwitterClient.h
//  twitter_client
//
//  Created by David Law on 2/1/14.
//  Copyright (c) 2014 David Law. All rights reserved.
//

#import "AFOAuth1Client.h"

@interface TwitterClient : AFOAuth1Client

+ (TwitterClient *)instance;

// Users API

- (void)authorizeWithCallbackUrl:(NSURL *)callbackUrl success:(void (^)(AFOAuth1Token *accessToken, id responseObject))success failure:(void (^)(NSError *error))failure;

- (void)currentUserWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id response))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

// Statuses API

- (void)homeTimelineWithCount:(int)count
                      sinceId:(int)sinceId
                        maxId:(int)maxId
                      success:(void (^)(AFHTTPRequestOperation *operation, id response))success
                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)favoriteTweet:(NSString *)tweetID
              success:(void (^)(AFHTTPRequestOperation *operation, id response))success
              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)unfavoriteTweet:(NSString *)tweetId
                success:(void (^)(AFHTTPRequestOperation *operation, id response))success
                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)retweetTweet:(NSString *)tweetID
             success:(void (^)(AFHTTPRequestOperation *operation, id response))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)composeTweet:(NSString *)text
             success:(void (^)(AFHTTPRequestOperation *operation, id response))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)destroyTweet:(NSString *)tweetID
             success:(void (^)(AFHTTPRequestOperation *operation, id response))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
