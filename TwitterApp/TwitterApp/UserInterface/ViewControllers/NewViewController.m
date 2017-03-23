//
//  NewViewController.m
//  TwitterApp
//
//  Created by Viktoriia Vovk on 3/23/17.
//  Copyright © 2017 Viktoriia Vovk. All rights reserved.
//

#import "NewViewController.h"

@interface NewViewController ()

@end

@implementation NewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationBar];
}

- (void)setupNavigationBar {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(onBackButtonItemTap)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(onSaveButtonTap)];
}

- (void)onBackButtonItemTap {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];

}
-(void)onSaveButtonTap {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
