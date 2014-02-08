//
//  Tweet.m
//  twitter_client
//
//  Created by David Law on 2/1/14.
//  Copyright (c) 2014 David Law. All rights reserved.
//

#import "Tweet.h"
#import <Parse/Parse.h>

@implementation Tweet

- (id)initWithDictionary:(NSDictionary *)data {
    self = [super initWithDictionary:data];
    
    self.tweetId = [data valueOrNilForKeyPath:@"id_str"];
    self.numFavorites = [[data valueOrNilForKeyPath:@"favorite_count"] integerValue];
    self.numRetweets = [[data valueOrNilForKeyPath:@"retweet_count"] integerValue];
    self.retweeted = [[data valueOrNilForKeyPath:@"retweeted"] boolValue];
    self.favorited = [[data valueOrNilForKeyPath:@"favorited"] boolValue];
    NSDictionary *user_retweet = [data valueOrNilForKeyPath:@"current_user_retweet"];
    if (user_retweet) {
        self.retweetId = [user_retweet valueOrNilForKeyPath:@"id_str"];
    }
    
    return self;
}

- (bool)canRetweet: (User *)user {
    if ([[user userId] isEqualToString:self.userId]) {
        NSLog(@"%@ - %@", self.userId, [user userId]);
        return NO;
    }
    
    return YES;
}

- (NSString *)text {
    if (self.isRetweet) {
        NSDictionary *retweetStatus = [self.data valueOrNilForKeyPath:@"retweeted_status"];
        return [retweetStatus valueOrNilForKeyPath:@"text" ];
    }
    
    return [self.data valueOrNilForKeyPath:@"text"];
}

- (NSDictionary *)user {
    if ([self isRetweet]) {
        NSDictionary *data = [self.data valueOrNilForKeyPath:@"retweeted_status"];
        return [data valueOrNilForKeyPath:@"user"];
        
    }
    return [self.data valueOrNilForKeyPath:@"user"];
}

- (NSString *)userId {
    return [self getUserInfo:@"id_str"];
}

- (NSString *)getUserInfo:(NSString *)key {
    NSDictionary *user = self.user;
    if (user) {
        return [user valueOrNilForKeyPath:key];
    }
    
    return nil;
}

- (NSString *)name {
    return [self getUserInfo:@"name"];
}

- (NSString *)screenName {
    return [NSString stringWithFormat:@"@%@", [self getUserInfo:@"screen_name"]];
}

- (NSURL *)profileImageURL {
    return [NSURL URLWithString:[self getUserInfo:@"profile_image_url_https"]];
}

- (bool)isRetweet {
    if ([self.data valueOrNilForKeyPath:@"retweeted_status"]) {
        return YES;
    }
    return NO;
}

- (NSString *)retweetHeaderText {
    if ([self isRetweet]) {
        NSDictionary *retweeter = [self.data valueOrNilForKeyPath:@"user"];
        if (retweeter) {
            return [NSString stringWithFormat:@"%@ retweeted",
                    [retweeter valueOrNilForKeyPath:@"name"]];
        }
    }
    return @"";
}

- (NSDate *) createdAt{
    NSString *createdAtText = [self.data valueOrNilForKeyPath:@"created_at"];
    if (createdAtText) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [df setDateFormat:@"EEE MMM d HH:mm:ss Z y"];
        return [df dateFromString:createdAtText];
    }
    return nil;
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

-(void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.data forKey:@"data"];
    [encoder encodeBool:self.favorited forKey:@"favorited"];
    [encoder encodeBool:self.retweeted forKey:@"retweeted"];
    [encoder encodeInteger:self.numFavorites forKey:@"numFavorites"];
    [encoder encodeInteger:self.numRetweets forKey:@"numRetweets"];
    [encoder encodeObject:self.tweetId forKey:@"tweetId"];
    [encoder encodeObject:self.retweetId forKey:@"retweetId"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.data = [decoder decodeObjectForKey:@"data"];
        self.favorited= [decoder decodeBoolForKey:@"favorited"];
        self.retweeted = [decoder decodeBoolForKey:@"retweeted"];
        self.numFavorites = [decoder decodeIntegerForKey:@"numFavorites"];
        self.numRetweets= [decoder decodeIntegerForKey:@"numRetweeted"];
        self.tweetId = [decoder decodeObjectForKey:@"tweetId"];
        self.retweetId = [decoder decodeObjectForKey:@"retweetId"];
    }
    return self;
}

- (void)favorite:(UIButton *)button {
    if ([button isSelected]) {
        [button setSelected:NO];
        self.favorited = NO;
        self.numFavorites -= 1;
        
        // Unfavorite tweet via Twitter API
        [[TwitterClient instance] unfavoriteTweet:self.tweetId success:^(AFHTTPRequestOperation *operation, id response) {
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Unfavorite unsuccessful! %@", error);
            NSLog(@"%@", self.tweetId);
        }];
    }
    else {
        [button setSelected:YES];
        
        self.favorited = YES;
        self.numFavorites += 1;
        
        // Favorite tweet via Twitter API
        [[TwitterClient instance] favoriteTweet:self.tweetId success:^(AFHTTPRequestOperation *operation, id response) {
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Favorite unsuccessful!: %@", error);
        }];
    };
}

- (void)retweet: (UIButton *)button {
    if (self.retweeted) {
        [button setSelected:NO];
        self.retweeted = NO;
        self.numRetweets -= 1;
        
        // Delete retweet via Twitter API
        [[TwitterClient instance] destroyTweet:self.retweetId success:^(AFHTTPRequestOperation *operation, id response) {
            NSLog(@"Successful removal of retweet");
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Unsuccessful removal of retweet %@", error);
        }];
        
    }
    else {
        [button setSelected:YES];
        self.retweeted = YES;
        self.numRetweets += 1;
        
        // Retweet via Twitter API
        [[TwitterClient instance] retweetTweet:self.tweetId success:^(AFHTTPRequestOperation *operation, id response) {
            self.retweeted = YES;
            self.retweetId = [response objectForKey:@"id_str"];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Unsucccessful retweet: %@", error);
        }];
    }

}

@end
