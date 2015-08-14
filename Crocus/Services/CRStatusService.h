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

@class CRStatus;


@interface CRStatusService : CRService
@property(nonatomic, copy) void (^callback)(BOOL);

@property(nonatomic, copy) void (^deleteCallback)(BOOL);

- (instancetype)initWithStatus:(CRStatus *)status callback:(void (^)(BOOL requestStatus))callback;

- (instancetype)initWithStatus:(CRStatus *)status callback:(void (^)(BOOL))callback deleteCallback:(void (^)(BOOL))deleteCallback;

- (void)post:(NSString *)message callback:(void (^)(BOOL status, NSError *error))callBack timerOn:(BOOL)yesOrNo;

- (void)update:(NSString *)message image:(UIImage *)image timerOn:(BOOL)yesOrNo callback:(void (^)(BOOL status, NSError *error))callback;

- (void)delete;

- (void)spread;

- (void)favourite;

- (void)reply;
@end