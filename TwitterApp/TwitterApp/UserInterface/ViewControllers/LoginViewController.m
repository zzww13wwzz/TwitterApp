//
//  LoginViewController.m
//  TwitterApp
//
//  Created by Viktoriia Vovk on 3/22/17.
//  Copyright © 2017 Viktoriia Vovk. All rights reserved.
//

#import "LoginViewController.h"
//#import "STTwitter.h"
#import "STTwitterOAuth.h"
#import <Accounts/Accounts.h>
#import "TwitterAPI.h"

@interface LoginViewController () <UIWebViewDelegate>

typedef void (^accountSelectionBlock_t)(ACAccount *account, NSString *errorMessage);

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (weak, nonatomic) IBOutlet UIButton *signInAccountButton;
@property (weak, nonatomic) IBOutlet UIButton *signInWebButton;

//@property (nonatomic, strong) STTwitterAPI *twitter;
@property (nonatomic, strong) STTwitterOAuth *oauth;
//@property (nonatomic, strong) TwitterAPI *twitterAPI;

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
        _oauth = [STTwitterOAuth twitterOAuthWithConsumerName:@"TwitterApp"
                                                  consumerKey:CONSUMER_KEY
                                               consumerSecret:CONSUMER_SECRET];
    }
    return _oauth;
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
    };
    [self chooseAccount];
}

- (IBAction)signInWebAction:(id)sender {
    
    [self.oauth postTokenRequest:^(NSURL *url, NSString *oauthToken)
     {
         NSURLRequest *request = [NSURLRequest requestWithURL:url];
         _webView.hidden = false;
         [_webView loadRequest:request];
     }
                   oauthCallback:@"myapp://testlinkviktoriiavovk.com"
                      errorBlock:^(NSError *error) {
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
    TwitterAPI * twitterAPI = [TwitterAPI new];
    [twitterAPI loadTweetWithIOSAccount:account
                             completion:^(NSError *error) {
                                 if (error) {
                                     [self showAlertWithString:nil withError:error];
                                 } else {
                                     [self goToNextScreen];
                                 }
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

- (void)goToNextScreen {
    [self.navigationController popViewControllerAnimated:YES];
//    [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"FeedVC"]
//                       animated:NO
//                     completion:nil];
//    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"FeedVC"]
//                                         animated:NO];
}

- (void) showAlertWithString:(NSString *)string withError:(NSError *)error  {
    NSString *title = nil;
    if (string == nil){
        string = error.localizedRecoverySuggestion;
        title = @"Error";
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:string
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Ok"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
