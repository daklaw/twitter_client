//
//  TwitterCommon.h
//  twitter_client
//
//  Created by David Law on 2/1/14.
//  Copyright (c) 2014 David Law. All rights reserved.
//

#ifndef twitter_client_TwitterCommon_h
#define twitter_client_TwitterCommon_h

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

// API
#import "TwitterClient.h"

// Models
#import "RestObject.h"
#import "User.h"
#import "Tweet.h"

// Categories
#import "NSDictionary+CPAdditions.h"

#endif
