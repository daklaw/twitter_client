//
//  TwitterClient.m
//  twitter_client
//
//  Created by David Law on 2/1/14.
//  Copyright (c) 2014 David Law. All rights reserved.
//

#import "TwitterClient.h"
#import "AFNetworking.h"

#define TWITTER_BASE_URL [NSURL URLWithString:@"https://api.twitter.com/"]
#define TWITTER_CONSUMER_KEY @"uiN8IWxOniwoDrSkTeeA"
#define TWITTER_CONSUMER_SECRET @"hqi1aykWFPT27g50XLHN56kdBLswAFwjsDs0pd5Go"


static NSString * const kAccessTokenKey = @"kAccessTokenKey";

@implementation TwitterClient

+ (TwitterClient *)instance {
    static dispatch_once_t once;
    static TwitterClient *instance;
    
    dispatch_once(&once, ^{
        instance = [[TwitterClient alloc] initWithBaseURL:TWITTER_BASE_URL key:TWITTER_CONSUMER_KEY secret:TWITTER_CONSUMER_SECRET];
    });
    
    return instance;
}

- (id)initWithBaseURL:(NSURL *)url key:(NSString *)key secret:(NSString *)secret {
    self = [super initWithBaseURL:TWITTER_BASE_URL key:TWITTER_CONSUMER_KEY secret:TWITTER_CONSUMER_SECRET];
    if (self != nil) {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        
        NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey:kAccessTokenKey];
        if (data) {
            self.accessToken = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
    }
    return self;
}

#pragma mark - Users API

- (void)authorizeWithCallbackUrl:(NSURL *)callbackUrl success:(void (^)(AFOAuth1Token *accessToken, id responseObject))success failure:(void (^)(NSError *error))failure {
    self.accessToken = nil;
    [super authorizeUsingOAuthWithRequestTokenPath:@"oauth/request_token" userAuthorizationPath:@"oauth/authorize" callbackURL:callbackUrl accessTokenPath:@"oauth/access_token" accessMethod:@"POST" scope:nil success:success failure:failure];
}
- (void)currentUserWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id response))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [self getPath:@"1.1/account/verify_credentials.json" parameters:nil success:success failure:failure];
}

#pragma mark - Statuses API

- (void)homeTimelineWithCount:(int)count sinceId:(int)sinceId maxId:(int)maxId success:(void (^)(AFHTTPRequestOperation *operation, id response))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"count": @(count)}];
    if (sinceId > 0) {
        [params setObject:@(sinceId) forKey:@"since_id"];
    }
    if (maxId > 0) {
        [params setObject:@(maxId) forKey:@"max_id"];
    }
    [params setObject:@"true" forKey:@"include_my_retweet"];
    
    [self getPath:@"1.1/statuses/home_timeline.json" parameters:params success:success failure:failure];
}


/* Favorites API Calls */
- (void)favoriteTweet:(NSString *)tweetId
              success:(void (^)(AFHTTPRequestOperation *operation, id response))success
              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    // TODO: fill out parameters
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:tweetId forKey:@"id"];
    
    NSLog(@"Parameters: %@", params);
    NSString *path = [NSString stringWithFormat:@"1.1/favorites/create.json"];
    
    [self postPath:path parameters:params success:success failure:failure];
}

- (void)unfavoriteTweet:(NSString *)tweetId
              success:(void (^)(AFHTTPRequestOperation *operation, id response))success
              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    // TODO: fill out parameters
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:tweetId forKey:@"id"];
    
    NSString *path = [NSString stringWithFormat:@"1.1/favorites/destroy.json"];
    
    [self postPath:path parameters:params success:success failure:failure];
}

/* Retweet API Calls */
- (void)retweetTweet:(NSString *)tweetId
             success:(void (^)(AFHTTPRequestOperation *operation, id response))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    // TODO: fill out parameters
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *path = [NSString stringWithFormat:@"1.1/statuses/retweet/%@.json", tweetId];
    
    [self postPath:path parameters:params success:success failure:failure];
}

/* Compose API Calls */

- (void)composeTweet:(NSString *)text
             success:(void (^)(AFHTTPRequestOperation *operation, id response))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    //TODO fill out parameters
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:text forKey:@"status"];
    
    [self postPath:@"1.1/statuses/update.json" parameters:params success:success failure:failure];
}

- (void)destroyTweet:(NSString *)tweetID
             success:(void (^)(AFHTTPRequestOperation *, id))success
             failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    
    // TODO: fill out parameters
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *path = [NSString stringWithFormat:@"1.1/statuses/destroy/%@.json", tweetID];
    [self postPath:path parameters:params success:success failure:failure];
}


#pragma mark - Private methods

- (void)setAccessToken:(AFOAuth1Token *)accessToken {
    [super setAccessToken:accessToken];
    if (accessToken) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:accessToken];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:kAccessTokenKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAccessTokenKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
