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
#import "CRTimeLineImageCell.h"
#import "CRStatus.h"
#import "UIImageView+WebCache.h"
#import "CREntities.h"


@implementation CRTimeLineImageCell {
    IBOutlet UIImageView *_statusImageView;
}

- (void)loadCRStatus:(CRStatus *)status {
    [super loadCRStatus:status];
    [_statusImageView sd_setImageWithURL:[[NSURL alloc] initWithString:status.entities.mediaURL] placeholderImage:nil];
}

@end