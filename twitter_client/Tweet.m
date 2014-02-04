//
//  Tweet.m
//  twitter_client
//
//  Created by David Law on 2/1/14.
//  Copyright (c) 2014 David Law. All rights reserved.
//

#import "Tweet.h"

@implementation Tweet

- (NSString *)text {
    return [self.data valueOrNilForKeyPath:@"text"];
}

- (id)initWithDictionary:(NSDictionary *)data {
    self = [super initWithDictionary:data];
    self.tweetId = [data valueOrNilForKeyPath:@"id_str"];
    NSDictionary *user = [data valueOrNilForKeyPath:@"user"];
    if (user) {
        self.name = [user valueOrNilForKeyPath:@"name"];
        self.screenName = [NSString stringWithFormat:@"@%@", [user valueOrNilForKeyPath:@"screen_name"]];
        self.profileImageURL = [NSURL URLWithString:[user valueOrNilForKeyPath:@"profile_image_url"]];
    }
    NSString *createdAtText = [data valueOrNilForKeyPath:@"created_at"];
    if (createdAtText) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [df setDateFormat:@"EEE MMM d HH:mm:ss Z y"];
        self.createdAt = [df dateFromString:createdAtText];
        
    }
    
    self.numFavorites = [[data valueOrNilForKeyPath:@"favorite_count"] integerValue];
    self.numRetweets = [[data valueOrNilForKeyPath:@"retweet_count"] integerValue];
    self.retweeted = [[data valueOrNilForKeyPath:@"retweeted"] boolValue];
    self.favorited = [[data valueOrNilForKeyPath:@"favorited"] boolValue];
    
    if (self.retweeted) {
        NSDictionary *user_retweet = [data valueOrNilForKeyPath:@"current_user_retweet"];
        if (user_retweet) {
            self.retweetId = [user_retweet valueOrNilForKeyPath:@"id_str"];
        }
    }
    
    return self;
}

+ (NSMutableArray *)tweetsWithArray:(NSArray *)array {
    NSMutableArray *tweets = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (NSDictionary *params in array) {
        [tweets addObject:[[Tweet alloc] initWithDictionary:params]];
    }
    return tweets;
}

- (NSString *)timeSinceStr {
    NSTimeInterval diff = [self.createdAt timeIntervalSinceNow]*-1;
    
    if (diff < 60) {
        return [NSString stringWithFormat:@"%.fs", diff];
    }
    else if (diff > 60 && diff < 3600) {
        diff = floor(diff / 60);
        return [NSString stringWithFormat:@"%.fm", diff];
    }
    else if (diff > 3600 && diff < 86400) {
        diff = floor(diff / 3600);
        return [NSString stringWithFormat:@"%.fh", diff];
    }
    else {
        diff = floor(diff / 86400);
        return [NSString stringWithFormat:@"%.fd", diff];
    }
}

@end
