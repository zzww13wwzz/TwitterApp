//
//  FeedTableViewController.m
//  TwitterApp
//
//  Created by Viktoriia Vovk on 3/22/17.
//  Copyright © 2017 Viktoriia Vovk. All rights reserved.
//

#import "FeedTableViewController.h"
#import "FeedTableViewCell.h"

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
    UIBarButtonItem * newButton = [[UIBarButtonItem alloc] initWithTitle:@"New"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(newAction)];
    UIBarButtonItem * backButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(logoutAction)];
    [self.navigationItem setRightBarButtonItem:newButton];
    [self.navigationItem setLeftBarButtonItem:backButton];

}

- (void)setupView {
    
    }
- (void) newAction {

}

- (void) logoutAction {
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Are you sure you want to logout?"
                                  message:nil
                                  preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"Logout"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action) {
                             [self logout];
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
    [alert addAction:ok];
    [alert addAction:cancel];
    
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
}

@end
