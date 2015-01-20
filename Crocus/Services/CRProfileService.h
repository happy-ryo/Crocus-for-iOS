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
#import "CRService.h"

@class CRUser;


@interface CRProfileService : CRService
- (instancetype)initWithUser:(CRUser *)user;

- (void)loadUserInfo:(void (^)(CRUser *user))callback;

- (void)mute:(void (^)(BOOL b))callback;

- (void)unMute:(void (^)(BOOL b))callback;

- (BOOL)isFollowed;

- (void)follow:(void (^)(BOOL result))callback;

- (void)unFollow:(void (^)(BOOL result))callback;

- (void)today:(void (^)(NSUInteger count))callback;
@end