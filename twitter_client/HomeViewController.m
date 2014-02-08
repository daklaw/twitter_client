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
- (void)reloadTweets;
- (void)fetchMoreTweets;
- (void)loadTweetsSince: (NSString *)sinceId numTweets:(int)numTweets;
- (void)loadTweetsBefore: (NSString *)maxId numTweets:(int)numTweets;
- (void)saveTweets;
- (void)popupModalController:(UIViewController *)viewController;
- (void)reloadTable;
- (void)fetchConnectionError;
- (void)showConnectionErrorHeader;
- (void)hideConnectionErrorHeader;
- (UILabel *)connectionErrorLabel;

@end

@implementation HomeViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [self retrieveTweetsFromDisk];
    if ([self.tweets count] == 0) {
        [self loadTweetsSince:@"0" numTweets:20];
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
    [refreshControl addTarget:self action:@selector(reloadTweets) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;

    // Turn Navigation Title text color to white and set title
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.title = @"Home";
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
    [cell.retweetButton setBackgroundImage:nil forState:UIControlStateDisabled];
    
    // Favorite setBackgroundImages
    [cell.favoriteButton setBackgroundImage:[UIImage imageNamed:@"favorite.png"] forState:UIControlStateNormal];
    [cell.favoriteButton setBackgroundImage:[UIImage imageNamed:@"favorite_on.png"] forState:UIControlStateSelected];
    

    // Keep track of whether tweet is already retweeted or favorited
    [cell.retweetButton setSelected:tweet.retweeted];
    [cell.favoriteButton setSelected:tweet.favorited];
    
    if (![tweet canRetweet:[User currentUser]]) {
        [cell.retweetButton setEnabled:NO];
    }
    
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
    float padding = 70.0f;
    float retweetLabelHeight = 12.0f;
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

    if (!tweet.isRetweet) {
        padding -= retweetLabelHeight;
    }
    return ceil(expectedFrame.size.height + padding);
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
    [tweet retweet:sender];
    [self reloadTable];
}

- (void)onFavorite:(UIButton *)sender {
    Tweet *tweet = self.tweets[sender.tag];
    [tweet favorite:sender];
    [self reloadTable];
}

- (void)reloadTweets {
    NSString *sinceId = @"0";
    if (self.tweets) {
        Tweet *tweet = self.tweets[0];
        sinceId = tweet.tweetId;
    }
    
    [self loadTweetsSince:sinceId numTweets:20];
    [self.refreshControl endRefreshing];
}

- (void)fetchMoreTweets {
    Tweet *lastTweet = [self.tweets lastObject];
    [self loadTweetsBefore:lastTweet.tweetId numTweets:20];
    [self reloadTable];
}

- (void)loadTweetsSince: (NSString *)sinceId numTweets:(int)numTweets  {
    [[TwitterClient instance] homeTimelineWithCount:numTweets sinceId:sinceId maxId:@"0" success:^(AFHTTPRequestOperation *operation, id response) {
        NSMutableArray *tweets = [Tweet tweetsWithArray:response];
        for (id tweet in self.tweets) {
            [tweets addObject:tweet];
        }
        self.tweets = tweets;
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([error code] == -1009) {
            [self refreshConnectionError];
        }
    }];
}

- (void)loadTweetsBefore: (NSString *)maxId numTweets:(int)numTweets {
    [[TwitterClient instance] homeTimelineWithCount:numTweets sinceId:@"0" maxId:maxId success:^(AFHTTPRequestOperation *operation, id response) {
        [self.tweets addObjectsFromArray:[Tweet tweetsWithArray:response]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([error code] == -1009) {
            [self fetchConnectionError];
        }
    }];
}

- (void)saveTweets {
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

- (void)updateTimeline: (NSNotification *)notification {
    NSDictionary* userInfo = notification.userInfo;
    Tweet *tweet = [userInfo objectForKey:@"tweet"];
    if (tweet) {
        [self.tweets insertObject:tweet atIndex:0];
        [self reloadTable];
    }
}

- (void)fetchConnectionError {
    [self.tableView setTableFooterView:[self connectionErrorLabel]];
}


- (void)refreshConnectionError {
    [self showConnectionErrorHeader];
    [NSTimer scheduledTimerWithTimeInterval:2
                                     target:self
                                   selector:@selector(hideConnectionErrorHeader)
                                   userInfo:nil
                                    repeats:NO];
}


- (void)showConnectionErrorHeader {
    [self.tableView setTableHeaderView:[self connectionErrorLabel]];
}

- (void) hideConnectionErrorHeader {
    //this is a selector that called automatically after time interval finished
    [self.tableView setTableHeaderView:nil];
    [self.tableView reloadData];
}

- (UILabel *)connectionErrorLabel {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    label.tag = -1009;
    label.textAlignment =  NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor blackColor];
    label.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(15.0)];
    label.text = @"No Internet Connection";
    return label;
}

- (void) reloadTable {
    [self.tableView reloadData];
    [self saveTweets];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData]; // to reload selected cell
}


@end
