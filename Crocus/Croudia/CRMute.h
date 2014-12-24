//  Copyright 2013 happy_ryo
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

static NSString *const CR_MUTE = @"CR_MUTE";

static NSString *const CR_MUTE_USER = @"crmuteuser";

static NSString *const CR_SCREEN_NAME = @"CR_SCREEN_NAME";

static NSString *const CR_USER_NAME = @"CR_USER_NAME";

@interface CRMute : NSObject
- (void)registration:(NSString *)muteId screenName:(NSString *)screenName name:(NSString *)name;

- (void)deletion:(NSString *)deleteId;

- (BOOL)check:(NSString *)checkId;

- (NSDictionary *)loadUser:(NSString *)userId;
@end