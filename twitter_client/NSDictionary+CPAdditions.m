//
//  NSDictionary+CPAdditions.m
//  twitter_client
//
//  Created by David Law on 2/1/14.
//  Copyright (c) 2014 David Law. All rights reserved.
//

#import "NSDictionary+CPAdditions.h"

@implementation NSDictionary (CPAdditions)

- (id)objectOrNilForKey:(id)key {
    id object = [self objectForKey:key];
    
    if ((NSNull *) object == [NSNull null] || [object isEqual:@"<null>"]) {
        return nil;
    }
    
    return object;
}

- (id)valueOrNilForKeyPath:(id)keyPath {
    id object = [self valueForKeyPath:keyPath];
    if ((NSNull *)object == [NSNull null] || [object isEqual:@"<null>"]) {
        return nil;
    }
    return object;
}

@end
