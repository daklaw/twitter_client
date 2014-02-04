//
//  TweetViewController.m
//  twitter_client
//
//  Created by David Law on 2/3/14.
//  Copyright (c) 2014 David Law. All rights reserved.
//

#import "TweetViewController.h"
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
    self.screenNameLabel.text = self.tweet.screenName;
    self.tweetLabel.text = self.tweet.text;
    self.numFavoriteLabel.text = [NSString stringWithFormat:@"%ld",(long)self.tweet.numFavorites];
    self.numRetweetLabel.text = [NSString stringWithFormat:@"%ld", (long)self.tweet.numRetweets];
    [self.tweetLabel sizeToFit];
    [self.profilePicture setImageWithURL:self.tweet.profileImageURL];
    
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
    if ([self.retweetButton isSelected]) {
        [self.retweetButton setSelected:NO];
        self.tweet.numRetweets -= 1;
        self.numRetweetLabel.text = [NSString stringWithFormat:@"%ld", (long)self.tweet.numRetweets];
        
        // Delete retweet via Twitter API
        [[TwitterClient instance] destroyTweet:self.tweet.retweetId success:^(AFHTTPRequestOperation *operation, id response) {
            self.tweet.retweeted = NO;
            self.tweet.retweetId = nil;

            NSLog(@"Successful removal of retweet");
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Unsuccessful removal of retweet %@", error);
        }];
    }
    else {
        [self.retweetButton setSelected:YES];
        self.tweet.numRetweets += 1;
        self.numRetweetLabel.text = [NSString stringWithFormat:@"%ld", (long)self.tweet.numRetweets];
        
        // Retweet it via Twitter API
        [[TwitterClient instance] retweetTweet:self.tweet.tweetId success:^(AFHTTPRequestOperation *operation, id response) {
            self.tweet.retweeted = YES;
            self.tweet.retweetId = [response objectForKey:@"id_str"];

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Unsucccessful retweet: %@", error);
        }];
    }

}

- (IBAction)onReply:(id)sender {
}

- (IBAction)onFavorite:(id)sender {
    if ([self.favoriteButton isSelected]) {
        [self.favoriteButton setSelected:NO];
        self.tweet.favorited = NO;
        self.tweet.numFavorites -= 1;
        self.numFavoriteLabel.text = [NSString stringWithFormat:@"%ld",(long)self.tweet.numFavorites];
        
        // Unfavorite tweet via Twitter API
        [[TwitterClient instance] unfavoriteTweet:self.tweet.tweetId success:^(AFHTTPRequestOperation *operation, id response) {
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Unfavorite unsuccessful! %@", error);
        }];
    }
    else {
        [self.favoriteButton setSelected:YES];
        
        self.tweet.favorited = YES;
        self.tweet.numFavorites += 1;
        self.numFavoriteLabel.text = [NSString stringWithFormat:@"%ld",(long)self.tweet.numFavorites];
        
        // Favorite tweet via Twitter API
        [[TwitterClient instance] favoriteTweet:self.tweet.tweetId success:^(AFHTTPRequestOperation *operation, id response) {
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Favorite unsuccessful!: %@", error);
        }];
    }
    
}

@end