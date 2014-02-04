//
//  ComposeViewController.m
//  twitter_client
//
//  Created by David Law on 2/3/14.
//  Copyright (c) 2014 David Law. All rights reserved.
//

#import "ComposeViewController.h"

@interface ComposeViewController ()
- (void) onCancel;
- (void) onTweet;
@end

@implementation ComposeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(onCancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Tweet"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(onTweet)];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tweetTextView.text = @"";
    [self.tweetTextView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) onCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) onTweet {
    [[TwitterClient instance] composeTweet:self.tweetTextView.text success:^(AFHTTPRequestOperation *operation, id response) {
        Tweet *tweet = [[Tweet alloc] initWithDictionary:response];
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setObject:tweet forKey:@"tweet"];
        [[NSNotificationCenter defaultCenter] postNotificationName:UserDidTweetNotification object:self userInfo:userInfo];
    }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Unsuccessful tweet: %@", error);
                                   }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
