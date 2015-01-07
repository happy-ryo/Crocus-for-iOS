//  Copyright 2015 happy_ryo
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
#import "CRTimeLineSpreadCell.h"
#import "CRStatus.h"
#import "CRUser.h"
#import "UIImageView+WebCache.h"


@implementation CRTimeLineSpreadCell {
    IBOutlet UIImageView *_iconImageView;
    IBOutlet UILabel *_userNameLabel;
    IBOutlet UILabel *_screenNameLabel;

    IBOutlet UIImageView *_spreadIconImageView;
    IBOutlet UILabel *_spreadUserNameLabel;
    IBOutlet UILabel *_spreadScreenNameLabel;
    IBOutlet UILabel *_spreadTextLabel;
    IBOutlet UIView *_spreadBackgroundView;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [_spreadBackgroundView.layer setCornerRadius:4];
    [_spreadBackgroundView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [_spreadBackgroundView.layer setBorderWidth:0.2f];
}


- (void)loadCRStatus:(CRStatus *)status {
    [_iconImageView sd_setImageWithURL:[[NSURL alloc] initWithString:status.user.profileImageUrlHttps] placeholderImage:nil];
    _userNameLabel.text = status.user.name;
    _screenNameLabel.text = [NSString stringWithFormat:@"@%@", status.user.screenName];

    CRStatus *spreadStatus = status.spreadStatus;
    [_spreadIconImageView sd_setImageWithURL:[[NSURL alloc] initWithString:spreadStatus.user.profileImageUrlHttps] placeholderImage:nil];
    _spreadUserNameLabel.text = spreadStatus.user.name;
    _spreadScreenNameLabel.text = [NSString stringWithFormat:@"@%@", spreadStatus.user.screenName];
    _spreadTextLabel.text = spreadStatus.text;
}
@end