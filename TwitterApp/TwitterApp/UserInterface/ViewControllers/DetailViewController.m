//
//  DetailViewController.m
//  TwitterApp
//
//  Created by Viktoriia Vovk on 3/22/17.
//  Copyright © 2017 Viktoriia Vovk. All rights reserved.
//

#import "DetailViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *userIconImageView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIView *scrollContentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contextViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageHeightConstraint;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void) setup {
    _userNameLabel.text = self.history.userName;
    _messageLabel.text = self.history.textMessage;
    _nickNameLabel.text = [NSString stringWithFormat:@"@%@", self.history.nickName];
    
    if (ValidString(self.history.userIconUrl)) {
        [_userIconImageView sd_setImageWithURL:[NSURL URLWithString:self.history.userIconUrl]];
    }
    else {
        _userIconImageView.backgroundColor = [UIColor grayColor];
    }
    
    _timeLabel.text = [self createdDateFormatted];
    _detailsLabel.text = [NSString stringWithFormat:@"%@ retweets, %@ likes", self.history.retweetCount, self.history.favoriteCount];
    
    [self optimizationMessageHeight];
//    _timeLabel.frame = CGRectMake(_timeLabel.frame.origin.x, _messageLabel.frame.origin.y + _messageLabel.frame.size.height, _timeLabel.frame.size.width, _timeLabel.frame.size.height);
    if (self.history.mediaUrls.count > 0){
        if ([self.history.isPhoto boolValue]) {
            for (NSString * link in self.history.mediaUrls) {
                UIImageView *view =[[UIImageView alloc] initWithFrame: CGRectMake(0,
                                                                                  (_contentView.frame.size.height) * [self.history.mediaUrls indexOfObject:link],
                                                                                  self.view.frame.size.width - _contentView.frame.origin.x*2,
                                                                                  _contentView.frame.size.height)];
                [view sd_setImageWithURL:[NSURL URLWithString:link]];
                view.contentMode = UIViewContentModeScaleAspectFit;
                [self.contentView addSubview:view];
                
            }
            self.contextViewHeightConstraint.constant = _contentView.frame.size.height * self.history.mediaUrls.count;
        } else {
            for (NSString * link in self.history.mediaUrls) {
                AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:link]];
                AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
                player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
                CALayer *superlayer = _contentView.layer;
                
                AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
                [playerLayer setFrame:CGRectMake(0, 0, self.view.frame.size.width - _contentView.frame.origin.x*2, _contentView.frame.size.height)];
                playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                [superlayer addSublayer:playerLayer];
                
                
                [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playerDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:item];
                
                [player seekToTime:kCMTimeZero];
                [player play];
            }
            self.contextViewHeightConstraint.constant = _contentView.frame.size.height * (self.history.mediaUrls.count+1);
            

        }
    } else {
        self.contextViewHeightConstraint.constant = 0;
    }
    self.scrollView.frame = self.view.frame;
    CGFloat height = self.contextViewHeightConstraint.constant + _detailsLabel.frame.size.height;
    self.scrollContentView.frame =  CGRectMake(0, 0, self.view.frame.size.width, height*2);
    self.scrollView.contentSize = self.scrollContentView.frame.size;
    self.scrollView.contentOffset = CGPointZero;
    self.automaticallyAdjustsScrollViewInsets = YES;
    //self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, height*2);

}

-(void)playerDidFinishPlaying:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

- (NSString *)createdDateFormatted {
    NSString * string =nil;
    NSDateFormatter * dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"h:mm a - dd MMM yyyy";
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    
    string = [dateFormatter stringFromDate:self.history.createdAt];
    return string;
}

- (void)optimizationMessageHeight {
    CGSize constraint = CGSizeMake(_messageLabel.frame.size.width, CGFLOAT_MAX);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [_messageLabel.text boundingRectWithSize:constraint
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName:_messageLabel.font}
                                                          context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    self.messageHeightConstraint.constant = size.height;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
