//
//  FeedTableViewController.m
//  TwitterApp
//
//  Created by Viktoriia Vovk on 3/22/17.
//  Copyright © 2017 Viktoriia Vovk. All rights reserved.
//

#import "FeedTableViewController.h"
#import "FeedTableViewCell.h"
#import "NewViewController.h"
#import "STTwitterAPI.h"

@interface FeedTableViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation FeedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self setupNavigation];
}





- (void) setupNavigation {
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"New"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(newAction)];
    self.navigationItem.leftBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:@"Logout"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(logoutAction)];
}

- (void)setupView {
    
//    twitterAPIOSWithFirstAccount
    
//    STTwitterAPI *twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:@"vlmu1T2Vpsh1vN9jzCxSntnRo" consumerSecret:@"By0VWWIipsJxATQ43vTJUGTBXDYZcYrcbFnDH1yD9vW8cuuKmE"];
//    
//    [twitter verifyCredentialsWithSuccessBlock:^(NSString *bearerToken) {
//        
//        NSLog(@"Access granted with %@", bearerToken);
//        
//        [twitter getUserTimelineWithScreenName:@"barackobama" successBlock:^(NSArray *statuses) {
//            NSLog(@"-- statuses: %@", statuses);
//        } errorBlock:^(NSError *error) {
//            NSLog(@"-- error: %@", error);
//        }];
//        
//    } errorBlock:^(NSError *error) {
//        NSLog(@"-- error %@", error);
//    }];
    
//    STTwitterAPI *twitter = [STTwitterAPI twitterAPIApplicationOnlyWithConsumerKey:OAUTH_CONSUMER_KEY consumerSecret:OAUTH_CONSUMER_SECRET];
//    
//    [twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
//        
//        [twitter getSearchTweetsWithQuery:searchQuery successBlock:^(NSDictionary *searchMetadata, NSArray *statuses) {
//            NSLog(@"Search data : %@",searchMetadata);
//            NSLog(@"\n\n Status : %@",statuses);
//            
//        } errorBlock:^(NSError *error) {
//            NSLog(@"Error : %@",error);
//        }];
//        
//    } errorBlock:^(NSError *error) {
//        NSLog(@"-- error %@", error);
//    }];
    
}

- (void) newAction {
    NewViewController * newVC = [self.storyboard instantiateViewControllerWithIdentifier:@"NewVC"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:newVC];
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.navigationController presentViewController:navController
                                            animated:YES
                                          completion:nil];
}

- (void) logoutAction {
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Are you sure you want to logout?"
                                  message:nil
                                  preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction
                       actionWithTitle:@"Logout"
                       style:UIAlertActionStyleDefault
                       handler:^(UIAlertAction * action) {
                           [self logout];
                           [alert dismissViewControllerAnimated:YES completion:nil];
                       }]];
    [alert addAction:[UIAlertAction
                      actionWithTitle:@"Cancel"
                      style:UIAlertActionStyleDefault
                      handler:^(UIAlertAction * action) {
                          [alert dismissViewControllerAnimated:YES completion:nil];
                      }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) logout {
//    [ApplicationDelegate cleanAndResetupDB];
    NSLog(@"LOGOUT");
//    [self.navigationController popToRootViewControllerAnimated:NO];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedTableViewCell *cell = (FeedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"FeedCell"];

    [cell setProperty:@"NEED SEND MODEL"];
    return cell;
}

- (void) tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"TAP TAp");
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"DetailVC"]
                                         animated:YES];
}

@end
