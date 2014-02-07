//
//  User.h
//  twitter_client
//
//  Created by David Law on 2/1/14.
//  Copyright (c) 2014 David Law. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RestObject.h"
#import <Parse/Parse.h>
#import "Tweet.h"

extern NSString *const UserDidLoginNotification;
extern NSString *const UserDidLogoutNotification;
extern NSString *const UserDidTweetNotification;


@interface User : RestObject


+ (User *)currentUser;
+ (void)setCurrentUser:(User *)currentUser;
- (NSURL *)profilePictureURL;
- (NSString *)name;
- (NSString *)screenName;

@property (nonatomic, strong) NSDictionary *data;

@end
