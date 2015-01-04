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
#import "CRTimeLineBaseCell.h"
#import "CRStatus.h"
#import "UIImageView+WebCache.h"
#import "CRUser.h"


@implementation CRTimeLineBaseCell {
    IBOutlet UIImageView *_iconImageView;
    IBOutlet UILabel *_statusLabel;
    IBOutlet UILabel *_userNameLabel;
    IBOutlet UILabel *_screenNameLabel;
}

- (void)loadCRStatus:(CRStatus *)status {
    [_iconImageView sd_setImageWithURL:[[NSURL alloc] initWithString:status.user.profileImageUrlHttps] placeholderImage:nil];
    _statusLabel.text = status.text;
    _userNameLabel.text = status.user.name;
    _screenNameLabel.text = [NSString stringWithFormat:@"@%@", status.user.screenName];
}
@end