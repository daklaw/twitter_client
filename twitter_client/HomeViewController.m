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

@end

@implementation HomeViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Twitter";
        
        [self reload];
    }
    return self;
}

- (void)viewDidLoad
{
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    [cell.tweetLabel sizeToFit];
    cell.tweetLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.nameLabel.text = tweet.name;
    cell.screenNameLabel.text = tweet.screenName;
    [cell.profilePicture setImageWithURL:tweet.profileImageURL];
    cell.timeSinceLabel.text = [tweet timeSinceStr];
    
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
    return 150.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TweetViewController *tweetViewController = [[TweetViewController alloc] initWithTweet:self.tweets[indexPath.row]];
    [self.navigationController pushViewController:tweetViewController animated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

- (void)onSignOutButton {
    [User setCurrentUser:nil];
}

- (void)onComposeButton {
    ComposeViewController *composeViewController = [[ComposeViewController alloc] init];

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:composeViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)onReply:(UIButton *)sender {
    NSLog(@"onReply: %d", sender.tag);
    Tweet *tweet = self.tweets[sender.tag];
    
    ComposeViewController *composeViewController = [[ComposeViewController alloc] initWithReply:tweet];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:composeViewController];
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
    [self.tableView reloadData];
}

- (void)reload {
    [[TwitterClient instance] homeTimelineWithCount:20 sinceId:0 maxId:0 success:^(AFHTTPRequestOperation *operation, id response) {
        self.tweets = [Tweet tweetsWithArray:response];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Do nothing
    }];
}

- (void)updateTimeline: (NSNotification *)notification {
    NSDictionary* userInfo = notification.userInfo;
    Tweet *tweet = [userInfo objectForKey:@"tweet"];
    if (tweet) {
        [self.tweets insertObject:tweet atIndex:0];
        [self.tableView reloadData];
    }
}

@end
