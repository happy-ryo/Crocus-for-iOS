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
#import <SDWebImage/UIImageView+WebCache.h>
#import "CRTimeLineImageSpreadCell.h"
#import "CRStatus.h"
#import "CREntities.h"


@implementation CRTimeLineImageSpreadCell {
    IBOutlet UIImageView *_statusImageView;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [_statusImageView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [_statusImageView.layer setBorderWidth:0.2f];
}

- (void)loadCRStatus:(CRStatus *)status {
    [super loadCRStatus:status];
    CRStatus *spreadStatus = status.spreadStatus;
    [_statusImageView sd_setImageWithURL:[[NSURL alloc] initWithString:spreadStatus.entities.mediaURL] placeholderImage:nil];
}
@end