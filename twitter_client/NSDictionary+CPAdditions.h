//
//  NSDictionary+CPAdditions.h
//  twitter_client
//
//  Created by David Law on 2/1/14.
//  Copyright (c) 2014 David Law. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (CPAdditions)

- (id)objectOrNilForKey:(id)key;
- (id)valueOrNilForKeyPath:(id)keyPath;

@end
