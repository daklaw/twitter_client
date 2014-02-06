//
//  HomeViewController.m
//  twitter_client
//
//  Created by David Law on 2/1/14.
//  Copyright (c) 2014 David Law. All rights reserved.
//

#import "HomeViewController.h"
#import "UIImageView+AFNetworking.h"
#import "TweetListCell.h"
#import "TweetViewController.h"
#import "ComposeViewController.h"

@interface HomeViewController ()

@property (nonatomic, strong) NSMutableArray *tweets;

- (void)updateTimeline: (NSNotification *)notification;
- (void)onSignOutButton;
- (void)onComposeButton;
- (void)onRetweet: (UIButton *) sender;
- (void)onReply: (UIButton *) sender;
- (void)onFavorite: (UIButton *) sender;
- (void)reload;
- (void)fetchMoreTweets;
- (void)saveTweets;
- (void)popupModalController:(UIViewController *)viewController;

@end

@implementation HomeViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Home";
        
    }
    return self;
}

- (void)viewDidLoad
{
    [self retrieveTweetsFromDisk];
    if ([self.tweets count] == 0) {
        [self reload];
    }
    
    [super viewDidLoad];
    
    UINib *customNib = [UINib nibWithNibName:@"TweetListCell" bundle:nil];
    [self.tableView registerNib:customNib forCellReuseIdentifier:@"TweetListCell"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sign Out"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(onSignOutButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"New"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(onComposeButton)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTimeline:) name:UserDidTweetNotification object:nil];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]
                                        init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Reloading Tweets"];
    [refreshControl addTarget:self action:@selector(reload) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.tweets count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TweetListCell";
    TweetListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    Tweet *tweet = self.tweets[indexPath.row];
    

    
    cell.tweetLabel.text = tweet.text;
    cell.tweetLabel.numberOfLines = 0;
    cell.tweetLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.nameLabel.text = tweet.name;
    cell.screenNameLabel.text = tweet.screenName;
    [cell.profilePicture setImageWithURL:[tweet profileImageURL]];
    cell.timeSinceLabel.text = [tweet timeSinceStr];
    
    if (tweet.isRetweet) {
        cell.optionalHeaderLabel.text = [tweet retweetHeaderText];
    }
    else {
        cell.retweetHeightConstraint.constant = 0;
    }
    
    // Configure the buttons
    // Retweet setBackgroundImages
    [cell.retweetButton setBackgroundImage: [UIImage imageNamed:@"retweet.png"] forState:UIControlStateNormal];
    [cell.retweetButton setBackgroundImage: [UIImage imageNamed:@"retweet_on.png"] forState:UIControlStateSelected];
    
    // Favorite setBackgroundImages
    [cell.favoriteButton setBackgroundImage:[UIImage imageNamed:@"favorite.png"] forState:UIControlStateNormal];
    [cell.favoriteButton setBackgroundImage:[UIImage imageNamed:@"favorite_on.png"] forState:UIControlStateSelected];
    

    // Keep track of whether tweet is already retweeted or favorited
    [cell.retweetButton setSelected:tweet.retweeted];
    [cell.favoriteButton setSelected:tweet.favorited];
    
    cell.replyButton.tag = indexPath.row;
    cell.retweetButton.tag = indexPath.row;
    cell.favoriteButton.tag = indexPath.row;
    [cell.replyButton addTarget:self action:@selector(onReply:) forControlEvents:UIControlEventTouchUpInside];
    [cell.retweetButton addTarget:self action:@selector(onRetweet:) forControlEvents:UIControlEventTouchUpInside];
    [cell.favoriteButton addTarget:self action:@selector(onFavorite:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    // Configure the cell...
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"TweetListCell";
    TweetListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *tweetLabel = cell.tweetLabel;
    
    Tweet *tweet = self.tweets[indexPath.row];
    CGRect expectedFrame = [tweet.text boundingRectWithSize:CGSizeMake(tweetLabel.frame.size.width, CGFLOAT_MAX)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                tweetLabel.font, NSFontAttributeName,
                                                                nil]
                                                       context:nil];

    return ceil(expectedFrame.size.height + 70.0f);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TweetViewController *tweetViewController = [[TweetViewController alloc] initWithTweet:self.tweets[indexPath.row]];
    [self.navigationController pushViewController:tweetViewController animated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (endScrolling >= scrollView.contentSize.height)
    {
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        spinner.frame=CGRectMake(0,0,50,50);
        [spinner startAnimating];
        
        self.tableView.tableFooterView=spinner;
        [self fetchMoreTweets];
    }
}


- (void)onSignOutButton {
    [User setCurrentUser:nil];
}

- (void)onComposeButton {
    ComposeViewController *composeViewController = [[ComposeViewController alloc] init];
    [self popupModalController:composeViewController];
}

- (void)onReply:(UIButton *)sender {
    Tweet *tweet = self.tweets[sender.tag];
    
    ComposeViewController *replyViewController = [[ComposeViewController alloc] initWithReply:tweet];
    [self popupModalController:replyViewController];
}

- (void)popupModalController:(UIViewController *)viewController {
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navigationController.navigationBar.barTintColor = [UIColor colorWithRed:(85/255.0) green:(172/255.0) blue:(238/255.0) alpha:1.0];
    navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

-(void)onRetweet:(UIButton *)sender {
    Tweet *tweet = self.tweets[sender.tag];
    if ([sender isSelected]) {
        [sender setSelected:NO];
        tweet.retweeted = NO;
        tweet.numRetweets -= 1;
        
        // Delete retweet via Twitter API
        [[TwitterClient instance] destroyTweet:tweet.retweetId success:^(AFHTTPRequestOperation *operation, id response) {
            NSLog(@"Successful removal of retweet");
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Unsuccessful removal of retweet %@", error);
        }];
        
    }
    else {
        [sender setSelected:YES];
        tweet.retweeted = YES;
        tweet.numRetweets += 1;
        
        // Retweet via Twitter API
        [[TwitterClient instance] retweetTweet:tweet.tweetId success:^(AFHTTPRequestOperation *operation, id response) {
            tweet.retweeted = YES;
            tweet.retweetId = [response objectForKey:@"id_str"];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Unsucccessful retweet: %@", error);
        }];
    }
    [self saveTweets];
    [self.tableView reloadData];
}

- (void)onFavorite:(UIButton *)sender {
    Tweet *tweet = self.tweets[sender.tag];
    if ([sender isSelected]) {
        [sender setSelected:NO];
        tweet.favorited = NO;
        tweet.numFavorites -= 1;
        
        // Unfavorite tweet via Twitter API
        [[TwitterClient instance] unfavoriteTweet:tweet.tweetId success:^(AFHTTPRequestOperation *operation, id response) {
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Unfavorite unsuccessful! %@", error);
        }];
    }
    else {
        [sender setSelected:YES];
        
        tweet.favorited = YES;
        tweet.numFavorites += 1;
        
        // Favorite tweet via Twitter API
        [[TwitterClient instance] favoriteTweet:tweet.tweetId success:^(AFHTTPRequestOperation *operation, id response) {
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Favorite unsuccessful!: %@", error);
        }];
    };
    [self saveTweets];
    [self.tableView reloadData];
}

- (void)reload {
    [[TwitterClient instance] homeTimelineWithCount:20 sinceId:@"0" maxId:@"0" success:^(AFHTTPRequestOperation *operation, id response) {
        self.tweets = [Tweet tweetsWithArray:response];
        [self.tableView reloadData];
        [self saveTweets];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Do nothing
    }];
    [self.refreshControl endRefreshing];
}

- (void)saveTweets {
    NSLog(@"Saving tweets");
    NSMutableArray *encodedTweets = [[NSMutableArray alloc] init];
    for (id tweet in self.tweets) {
        [encodedTweets addObject:[NSKeyedArchiver archivedDataWithRootObject:tweet]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:encodedTweets forKey:@"tweets"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)retrieveTweetsFromDisk {
    NSArray *encodedTweets = [[NSUserDefaults standardUserDefaults] objectForKey:@"tweets"];
    self.tweets = [[NSMutableArray alloc] initWithCapacity:[encodedTweets count]];
    if (encodedTweets) {
        for (id encodedTweet in encodedTweets) {
            [self.tweets addObject:[NSKeyedUnarchiver unarchiveObjectWithData:encodedTweet]];
        }
    }
}

- (void)fetchMoreTweets {
    Tweet *lastTweet = [self.tweets lastObject];
    [[TwitterClient instance] homeTimelineWithCount:20 sinceId:@"0" maxId:lastTweet.tweetId success:^(AFHTTPRequestOperation *operation, id response) {
        NSMutableArray *newTweets = [Tweet tweetsWithArray:response];
        [self.tweets addObjectsFromArray:newTweets];
        [self.tableView reloadData];
        [self saveTweets];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure: %@", error);
        // Do nothing
    }];
}

- (void)updateTimeline: (NSNotification *)notification {
    NSDictionary* userInfo = notification.userInfo;
    Tweet *tweet = [userInfo objectForKey:@"tweet"];
    if (tweet) {
        [self.tweets insertObject:tweet atIndex:0];
        [self.tableView reloadData];
        [self saveTweets];
    }
}


@end
