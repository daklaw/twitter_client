//
//  ComposeViewController.h
//  twitter_client
//
//  Created by David Law on 2/3/14.
//  Copyright (c) 2014 David Law. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComposeViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;

- (id)initWithReply:(Tweet *)tweet;
@end
