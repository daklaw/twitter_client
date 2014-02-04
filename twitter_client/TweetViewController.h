//
//  TweetViewController.h
//  twitter_client
//
//  Created by David Law on 2/3/14.
//  Copyright (c) 2014 David Law. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UILabel *tweetLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *numRetweetLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *numFavoriteLabel;
@property (weak, nonatomic) IBOutlet UILabel *favoriteTextLabel;
- (id)initWithTweet:(Tweet *)tweet;

@end
