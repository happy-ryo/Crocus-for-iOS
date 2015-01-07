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
#import "CRStatus.h"
#import "CRSource.h"
#import "CRUser.h"
#import "CREntities.h"


@implementation CRStatus {
    NSString *_createdAt;
    BOOL _favorited;
    NSNumber *_favoritedCount;
    NSString *_idStr;
    NSNumber *_idNum;
    NSString *_inReplyToScreenName;
    NSString *_inReplyToStatusIdStr;
    NSNumber *_inReplyToStatusId;
    NSString *_inReplyToUserIdStr;
    NSNumber *_inReplyToUserId;
    NSNumber *_spreadCount;
    BOOL _spread;
    CRStatus *_spreadStatus;
    CRStatus *_replyStatus;
    CRSource *_source;
    NSString *_text;
    CRUser *_user;
    CREntities *_entities;
}

- (BOOL)isExistImageSpread {
    return _spreadStatus.entities.mediaURL != nil ?: NO;
}

- (BOOL)isSpreadStatus {
    return _spreadStatus != nil ?: NO;
}

- (BOOL)isExistImage {
    return _entities.mediaURL != nil ?: NO;
}
@end