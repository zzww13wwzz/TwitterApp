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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mediaContentHeightConstraint;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupViews];
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
    _messageLabel.frame  = CGRectMake(_messageLabel.frame.origin.x,
                                      _messageLabel.frame.origin.y,
                                      _messageLabel.frame.size.width,
                                      [self optimizationMessageHeight]);
    
    self.mediaContentHeightConstraint.constant = self.contentView.frame.size.height * self.history.mediaUrls.count;
    
}

- (void) setupViews {
    self.scrollView.frame = self.view.bounds;
    
    self.scrollView.contentSize = self.scrollView.frame.size;
    self.scrollView.contentOffset = CGPointZero;
    if (self.history.mediaUrls.count > 0){
        if ([self.history.isPhoto boolValue]) {
            for (NSString * link in self.history.mediaUrls) {
                NSLog(@"self.history.mediaUrls.count = %lu", self.history.mediaUrls.count);
                CGRect frame = CGRectMake(0,
                                          (_contentView.frame.size.height) * [self.history.mediaUrls indexOfObject:link],
                                          self.view.frame.size.width - _contentView.frame.origin.x*2,
                                          _contentView.frame.size.height);
                
                UIImageView *view =[[UIImageView alloc] initWithFrame:frame];
                view.contentMode = UIViewContentModeScaleAspectFit;
                [view sd_setImageWithURL:[NSURL URLWithString:link]];
                
                [self.contentView addSubview:view];
            }
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
        }
    }
    float cpn = self.mediaContentHeightConstraint.constant + self.detailsLabel.frame.size.height +1 +self.contentView.frame.origin.y;
    
    self.scrollContentView.frame = CGRectMake(_scrollContentView.frame.origin.x,
                                              _scrollContentView.frame.origin.y,
                                              self.scrollView.frame.size.width,
                                              cpn);
    
    self.scrollView.scrollEnabled = (self.scrollView.contentSize.height < cpn);
    
    
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

- (CGFloat)optimizationMessageHeight {
    CGSize constraint = CGSizeMake(_messageLabel.frame.size.width, CGFLOAT_MAX);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [_messageLabel.text boundingRectWithSize:constraint
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName:_messageLabel.font}
                                                          context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    return size.height;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
