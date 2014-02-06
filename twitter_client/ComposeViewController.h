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
@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *screenNameLabel;

- (id)initWithReply:(Tweet *)tweet;
@end
