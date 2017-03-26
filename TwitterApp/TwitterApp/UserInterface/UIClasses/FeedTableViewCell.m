//
//  FeedTableViewCell.m
//  TwitterApp
//
//  Created by Viktoriia Vovk on 3/22/17.
//  Copyright © 2017 Viktoriia Vovk. All rights reserved.
//

#import "FeedTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface FeedTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation FeedTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self layoutIfNeeded];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)setProperty:(NSString *)property {
    self.nameLabel.text = property;
}


- (void) setHistory:(History *)history
{
    _history = history;
    
    _nameLabel.text = history.userName;
    
    _messageLabel.text = history.textMessage;
    
    if (ValidString(_history.userIconUrl)) {
        [_iconImageView sd_setImageWithURL:[NSURL URLWithString:_history.userIconUrl]
                             placeholderImage:[UIImage imageNamed:@"img_diamond"]];
    }
    else {
        _iconImageView.image = [UIImage imageNamed:@"img_diamond"];
    }

}


@end
