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
//#import "STTwitterAPI.h"
#import "TwitterAPI.h"

@interface FeedTableViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray * historyArray;

@end

@implementation FeedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigation];
   // [self loadFeed];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadFeed];
}

- (void)loadFeed {
    [ApplicationDelegate cleanAndResetupDB];
    
    TwitterAPI * twitterAPI = [TwitterAPI new];
    
    [twitterAPI loadTweetWithIOSAccount:nil
                             completion:^(NSError *error) {
                                 if (error) {
                                     [self showAlertWithString:nil withError:error];
                                 } else {
                                     [self reloadItems];
                                 }
                             }];
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

- (void) reloadItems {
    _historyArray = [[[History MR_findAll] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt"
                                                                                                       ascending:NO]]] mutableCopy];
    
    [_tableView reloadData];
    
//    _noHistoryLabel.hidden = (_historyArray.count > 0);
}


- (void) newAction {
    NewViewController * newVC = [self.storyboard instantiateViewControllerWithIdentifier:@"NewVC"];
//    _account
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
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userID"];
    
    [ApplicationDelegate cleanAndResetupDB];
    
    NSString * accountName =[[NSUserDefaults standardUserDefaults] objectForKey:@"account.username"];
    if (accountName) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"account.username"];
    }
    
    NSLog(@"LOGOUT");
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - tableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.;
}
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return _historyArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedTableViewCell *cell = (FeedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"FeedCell"];

    cell.history = _historyArray[indexPath.row];
    return cell;
    
//    [cell setProperty:@"NEED SEND MODEL"];
//    return cell;
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




- (void) tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"TAP TAp");
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"DetailVC"]
                                         animated:YES];
}

@end
