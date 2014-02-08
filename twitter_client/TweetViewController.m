//
//  TweetViewController.m
//  twitter_client
//
//  Created by David Law on 2/3/14.
//  Copyright (c) 2014 David Law. All rights reserved.
//

#import "TweetViewController.h"
#import "ComposeViewController.h"
#import "UIImageView+AFNetworking.h"

@interface TweetViewController ()

@property (nonatomic, strong) Tweet *tweet;

- (IBAction)onRetweet:(id)sender;
- (IBAction)onReply:(id)sender;
- (IBAction)onFavorite:(id)sender;

@end

@implementation TweetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithTweet:(Tweet *)tweet {
    if (self = [super init]) {
        self.tweet = tweet;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Retweet setBackgroundImages
    [self.retweetButton setBackgroundImage: [UIImage imageNamed:@"retweet.png"] forState:UIControlStateNormal];
    [self.retweetButton setBackgroundImage: [UIImage imageNamed:@"retweet_on.png"] forState:UIControlStateSelected];
    
    // Favorite setBackgroundImages
    [self.favoriteButton setBackgroundImage:[UIImage imageNamed:@"favorite.png"] forState:UIControlStateNormal];
    [self.favoriteButton setBackgroundImage:[UIImage imageNamed:@"favorite_on.png"] forState:UIControlStateSelected];
    
    // Keep track of whether tweet is already retweeted or favorited
    [self.retweetButton setSelected:self.tweet.retweeted];
    [self.favoriteButton setSelected:self.tweet.favorited];
    
    // Do any additional setup after loading the view from its nib.
    self.nameLabel.text = self.tweet.name;
    self.screenNameLabel.text = [self.tweet screenName];
    self.tweetLabel.text = self.tweet.text;
    self.numFavoriteLabel.text = [NSString stringWithFormat:@"%ld",(long)self.tweet.numFavorites];
    self.numRetweetLabel.text = [NSString stringWithFormat:@"%ld", (long)self.tweet.numRetweets];
    [self.tweetLabel sizeToFit];
    [self.profilePicture setImageWithURL:[self.tweet profileImageURL]];
    
    if (self.tweet.isRetweet) {
        self.optionalHeaderLabel.text = [self.tweet retweetHeaderText];
    }
    else {
        [self.optionalHeaderLabel removeFromSuperview];
        self.retweetHeightConstraint.constant = 0;
    }
    
    
    if (![self.tweet canRetweet:[User currentUser]]) {
        [self.retweetButton setEnabled:NO];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [formatter setDateFormat:@"M/d/yy hh:mm a"];
    
    //Optionally for time zone converstions
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    
    NSString *stringFromDate = [formatter stringFromDate:self.tweet.createdAt];
    self.timestampLabel.text = stringFromDate;
    
    // So the Navigation Controller does not overlay on the interface
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onRetweet:(id)sender {
    if (self.tweet.retweeted) {
        self.numRetweetLabel.text = [NSString stringWithFormat:@"%ld", (long)self.tweet.numRetweets-1];
    }
    else {
        self.numRetweetLabel.text = [NSString stringWithFormat:@"%ld", (long)self.tweet.numRetweets+1];
    }
    [self.tweet retweet:self.retweetButton];

}

- (IBAction)onReply:(id)sender {
    ComposeViewController *composeViewController = [[ComposeViewController alloc] initWithReply:self.tweet];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:composeViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)onFavorite:(id)sender {
    if ([self.tweet favorited]) {
        self.numFavoriteLabel.text = [NSString stringWithFormat:@"%ld", (long)self.tweet.numFavorites-1];
    }
    else {
        self.numFavoriteLabel.text = [NSString stringWithFormat:@"%ld", (long)self.tweet.numFavorites+1];
    }
    [self.tweet favorite:self.favoriteButton];
}

@end
