//
//  User.h
//  twitter_client
//
//  Created by David Law on 2/1/14.
//  Copyright (c) 2014 David Law. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RestObject.h"

extern NSString *const UserDidLoginNotification;
extern NSString *const UserDidLogoutNotification;
extern NSString *const UserDidTweetNotification;


@interface User : RestObject

+ (User *)currentUser;
+ (void)setCurrentUser:(User *)currentUser;
- (id)initWithDictionary:(NSDictionary *)data;

@property (nonatomic, strong) NSDictionary *data;

@end
