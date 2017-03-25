//
//  LoginViewController.m
//  TwitterApp
//
//  Created by Viktoriia Vovk on 3/22/17.
//  Copyright © 2017 Viktoriia Vovk. All rights reserved.
//

#import "LoginViewController.h"
#import "STTwitter.h"
#import "STTwitterOAuth.h"
#import <Accounts/Accounts.h>

NSString * const consumerKey = @"vlmu1T2Vpsh1vN9jzCxSntnRo";
NSString * const consumerSecret = @"By0VWWIipsJxATQ43vTJUGTBXDYZcYrcbFnDH1yD9vW8cuuKmE";

@interface LoginViewController () <UIWebViewDelegate>

typedef void (^accountSelectionBlock_t)(ACAccount *account, NSString *errorMessage);

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (weak, nonatomic) IBOutlet UIButton *signInAccountButton;
@property (weak, nonatomic) IBOutlet UIButton *signInWebButton;

@property (nonatomic, strong) STTwitterAPI *twitter;
@property (nonatomic, strong) STTwitterOAuth *oauth;

@property (nonatomic, strong) accountSelectionBlock_t accountSelectionBlock;

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) NSArray *iOSAccounts;

@end


@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.accountStore = [[ACAccountStore alloc] init];
    _webView.hidden = true;
}

- (STTwitterOAuth *)oauth {
    if (!_oauth) {
        _oauth = [STTwitterOAuth twitterOAuthWithConsumerName:@"TwitterApp" consumerKey:consumerKey consumerSecret:consumerSecret];
    }
    return _oauth;
}

- (void) showAlertWithString:(NSString *)string withError:(NSError *)error  {
    if (string == nil){
        string = error.localizedRecoverySuggestion;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:string
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Ok"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)signInAccountAction:(id)sender {
    
    __weak typeof(self) weakSelf = self;
    
    self.accountSelectionBlock = ^(ACAccount *account, NSString *errorMessage) {
        if (errorMessage) {
            [weakSelf showAlertWithString:errorMessage withError:nil];
        }
        if (account) {
            [weakSelf loginWithiOSAccount:account];
        }
        //[weakSelf.signInAccountButton setTitle:status forState:UIControlStateNormal];
    };
    [self chooseAccount];
}

- (IBAction)signInWebAction:(id)sender {

    [self.oauth postTokenRequest:^(NSURL *url, NSString *oauthToken) {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        _webView.hidden = false;
        [_webView loadRequest:request];
    } oauthCallback:@"myapp://testlinkviktoriiavovk.com" errorBlock:^(NSError *error) {
        [self showAlertWithString:nil withError:error];
    }];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = [request URL];
    NSLog(@"Loading URL: %@", [url absoluteString]);
    if ([[url host] isEqualToString:@"testlinkviktoriiavovk.com"]) {
        _webView.hidden = true;
        NSString * str = [self verifier:url.absoluteString];
        [self sendAccessToken:str];
        return NO;
    }
    return YES;
}

-(NSString *)verifier:(NSString *)string {
    //NSString * str = @"Loading URL: myapp://testlinkviktoriiavovk.com?oauth_token=LjqBAwAAAAAAzxAaAAABWwHcSho&oauth_verifier=RJynI1kZtr36yWNIW64SSVZkz2Bz101x";
    NSString * key = @"auth_verifier=";
    NSRange   range = [string rangeOfString:@"auth_verifier="];
    NSInteger location = range.location + key.length;
    NSString * str = [string substringWithRange:NSMakeRange(location, string.length-location)];
    NSLog(@"string %@", str);

    return str;
}

-(void)sendAccessToken:(NSString *)oauth_verifier {
    [self.oauth postAccessTokenRequestWithPIN:oauth_verifier successBlock:^(NSString *oauthToken,
                                                                            NSString *oauthTokenSecret,
                                                                            NSString *userID,
                                                                            NSString *screenName) {
        
        [[NSUserDefaults standardUserDefaults] setObject:oauthToken forKey:@"oauthToken"];
        [[NSUserDefaults standardUserDefaults] setObject:oauthTokenSecret forKey:@"oauthTokenSecret"];
        
        /*
         At this point, the user can use the API and you can read his access tokens with:
         
         _twitter.oauthAccessToken;
         _twitter.oauthAccessTokenSecret;
         
         You can store these tokens (in user default, or in keychain) so that the user doesn't need to authenticate again on next launches.
         
         Next time, just instanciate STTwitter with the class method:
         
         +[STTwitterAPI twitterAPIWithOAuthConsumerKey:consumerSecret:oauthToken:oauthTokenSecret:]
         
         Don't forget to call the -[STTwitter verifyCredentialsWithSuccessBlock:errorBlock:] after that.
         */
        
        [self loginWithiOSAccount:nil];
        //[[NSUserDefaults standardUserDefaults] synchronize];
    } errorBlock:^(NSError *error) {
        [self showAlertWithString:nil withError:error];
    }];
}


- (void)loginWithiOSAccount:(ACAccount *)account {
    _twitter = nil;
    if (account) {
        
        _twitter = [STTwitterAPI twitterAPIOSWithFirstAccountAndDelegate:nil];
        
        
    } else {
        _twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:consumerKey
                                                 consumerSecret:consumerSecret
                                                     oauthToken:[[NSUserDefaults standardUserDefaults] valueForKey:@"oauthToken"]
                                               oauthTokenSecret:[[NSUserDefaults standardUserDefaults] valueForKey:@"oauthTokenSecret"]];
        

    }
    [_twitter verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
        [_twitter getHomeTimelineSinceID:nil
                                   count:5
                            successBlock:^(NSArray *statuses) {
                                
                                NSLog(@"-- statuses: %@", statuses);
                                
                                //self.getTimelineStatusLabel.text = [NSString stringWithFormat:@"%lu statuses", (unsigned long)[statuses count]];
                                
                                //self.statuses = statuses;
                                
                                //[self.tableView reloadData];
                                
                            } errorBlock:^(NSError *error) {
                                [self showAlertWithString:nil withError:error];
                                NSLog(@"%@", error);
                                //self.getTimelineStatusLabel.text = [error localizedDescription];
                            }];
        //_loginStatusLabel.text = [NSString stringWithFormat:@"@%@ (%@)", username, userID];
        
    } errorBlock:^(NSError *error) {
        [self showAlertWithString:nil withError:error];
        // _loginStatusLabel.text = [error localizedDescription];
    }];
    
}

- (void)chooseAccount {
    
    ACAccountType *accountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    ACAccountStoreRequestAccessCompletionHandler accountStoreRequestCompletionHandler = ^(BOOL granted, NSError *error) {
        if (error) {
            [self showAlertWithString:nil withError:error];
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            if(granted == NO) {
                _accountSelectionBlock(nil, @"Acccess not granted.");
                return;
            }
            self.iOSAccounts = [_accountStore accountsWithAccountType:accountType];
            if([_iOSAccounts count] < 1) {
                _accountSelectionBlock(nil, @"Twitter account not found. Please add in the settings.");
                return;
            }
            
            if([_iOSAccounts count] == 1) {
                ACAccount *account = [_iOSAccounts lastObject];
                _accountSelectionBlock(account, nil);
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select an account:"
                                                                               message:nil
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                          style:UIAlertActionStyleCancel
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                        }]];
                for(ACAccount *account in _iOSAccounts) {
                    [alert addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"@%@", account.username]
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action) {
                                                                _accountSelectionBlock(account, nil);                                                            }]];
                }
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];
    };
    
    [self.accountStore requestAccessToAccountsWithType:accountType
                                               options:NULL
                                            completion:accountStoreRequestCompletionHandler];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
