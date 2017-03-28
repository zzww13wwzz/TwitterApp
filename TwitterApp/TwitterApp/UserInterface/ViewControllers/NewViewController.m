//
//  NewViewController.m
//  TwitterApp
//
//  Created by Viktoriia Vovk on 3/23/17.
//  Copyright © 2017 Viktoriia Vovk. All rights reserved.
//

#import "NewViewController.h"
#import "TwitterAPI.h"

@interface NewViewController ()
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
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
    if (!ValidString(_messageTextView.text)) {
        [self showAlertWithString:@"Message is empty" withError:nil];
    }
    
    TwitterAPI * twitterAPI = [TwitterAPI new];
    [twitterAPI postTweetWithMessage:_messageTextView.text
                          completion:^(NSError *error) {
                              if (error) {
                                  [self showAlertWithString:nil withError:error];
                              } else {
                                  [_messageTextView resignFirstResponder];
                                  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Successful!"
                                                                                                 message:nil
                                                                                          preferredStyle:UIAlertControllerStyleAlert];
                                  [alert addAction:[UIAlertAction actionWithTitle:@"Ok"
                                                                            style:UIAlertActionStyleCancel
                                                                          handler:^(UIAlertAction * action) {
                                                                              [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                                                                          }]];
                                  [self presentViewController:alert animated:YES completion:nil];
                              }
                              
                          }];
    //[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) showAlertWithString:(NSString *)string withError:(NSError *)error  {
    NSString *title = nil;
    if (string == nil){
        string = [error localizedDescription];
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
