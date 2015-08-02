/*
 * Copyright (C) 2015 happy_ryo
 *      https://twitter.com/happy_ryo
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>
#import "CRService.h"
#import "CRUpdateProfile.h"
#import "CRUpdateProfileImage.h"

@class CRStatus;
@class CRUser;


static NSString *const USER_INFO_KEY = @"crocusUserInfo";

@interface CRUserInfoService : CRService
- (void)loadUserInfo;

- (void)saveUser:(CRUser *)user;

- (BOOL)isExistUserInfo;

- (BOOL)isExistUserIcon;

- (BOOL)replyCheck:(CRStatus *)status;

- (BOOL)checkMineStatus:(CRStatus *)status;

- (CRUser *)getUser;

- (void)deleteTodayStatuses:(void (^)(NSUInteger count))callback;

- (void)deleteAllStatuses:(void (^)(NSUInteger count))callback;

- (void)protect:(BOOL)status updateFinish:(UpdateFinished)pFunction;

- (void)startTimer:(BOOL)status;

- (void)timer:(NSString *)timerSec updateFinish:(UpdateFinished)pFunction;
@end