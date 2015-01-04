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
#import <Foundation/Foundation.h>

@class CRSource;
@class CRUser;
@class CREntities;


@interface CRStatus : NSObject
@property(nonatomic, copy) NSString *createdAt;
@property(nonatomic) BOOL favorited;
@property(nonatomic, strong) NSNumber *favoritedCount;
@property(nonatomic, copy) NSString *idStr;
@property(nonatomic, strong) NSNumber *idNum;
@property(nonatomic, copy) NSString *inReplyToScreenName;
@property(nonatomic, copy) NSString *inReplyToStatusIdStr;
@property(nonatomic, strong) NSNumber *inReplyToStatusId;
@property(nonatomic, copy) NSString *inReplyToUserIdStr;
@property(nonatomic, strong) NSNumber *inReplyToUserId;
@property(nonatomic, strong) NSNumber *spreadCount;
@property(nonatomic, strong) CRStatus *spreadStatus;
@property(nonatomic, strong) CRStatus *replyStatus;
@property(nonatomic, strong) CRSource *source;
@property(nonatomic, copy) NSString *text;
@property(nonatomic, strong) CRUser *user;
@property(nonatomic) BOOL spread;
@property(nonatomic, strong) CREntities *entities;
@end