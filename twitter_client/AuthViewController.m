//
//  AuthViewController.m
//  twitter_client
//
//  Created by David Law on 2/1/14.
//  Copyright (c) 2014 David Law. All rights reserved.
//

#import "AuthViewController.h"

@interface AuthViewController ()
@property (strong, nonatomic) IBOutlet UIButton *loginButton;

@property (strong, nonatomic) IBOutlet UIButton *twitterImage;
- (IBAction)onLoginButton:(id)sender;
- (void)onError;
- (void)getUserFromAccessToken;

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
    [self.view setBackgroundColor:[UIColor colorWithRed:(85/255.0) green:(172/255.0) blue:(238/255.0) alpha:1.0]];
    [self.loginButton setBackgroundColor:[UIColor colorWithRed:(85/255.0) green:(172/255.0) blue:(238/255.0) alpha:1.0]];
    [self.twitterImage addTarget:self action:@selector(onLoginButton:) forControlEvents:UIControlEventTouchUpInside];
    //[self.twitterImage setImage:[UIImage imageNamed:@"Twitter_logo_white"]];
    [self getUserFromAccessToken];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onLoginButton:(id)sender {
    [[TwitterClient instance] authorizeWithCallbackUrl:[NSURL URLWithString:@"dl-twitter://success"] success:^(AFOAuth1Token *accessToken, id responseObject) {
        [self getUserFromAccessToken];
        NSLog(@"success!");
    } failure:^(NSError *error) {
        [self onError];
    }];
}

- (void)getUserFromAccessToken {
    [[TwitterClient instance] currentUserWithSuccess:^(AFHTTPRequestOperation *operation, id response) {
        [User setCurrentUser:[[User alloc] initWithDictionary:response]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}

- (void)onError {
    [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Couldn't log in with Twitter, please try again!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
