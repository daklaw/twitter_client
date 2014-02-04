//
//  AuthViewController.m
//  twitter_client
//
//  Created by David Law on 2/1/14.
//  Copyright (c) 2014 David Law. All rights reserved.
//

#import "AuthViewController.h"

@interface AuthViewController ()

- (IBAction)onLoginButton:(id)sender;
- (void)onError;

@end

@implementation AuthViewController

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
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onLoginButton:(id)sender {
    [[TwitterClient instance] authorizeWithCallbackUrl:[NSURL URLWithString:@"dl-twitter://success"] success:^(AFOAuth1Token *accessToken, id responseObject) {
        [[TwitterClient instance] currentUserWithSuccess:^(AFHTTPRequestOperation *operation, id response) {
            [User setCurrentUser:[[User alloc] initWithDictionary:response]];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self onError];
        }];
        NSLog(@"success!");
    } failure:^(NSError *error) {
        [self onError];
    }];
}

- (void)onError {
    [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Couldn't log in with Twitter, please try again!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

@end