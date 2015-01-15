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
@class CRPublicTimeLine;
@class CRTimeLine;


@interface CRTimeLineService : CRService{
    dispatch_semaphore_t _semaphore;
}
@property(nonatomic, strong) CRTimeLine *publicTimeLine;
@property(nonatomic, copy) void (^loaded)(NSArray *, BOOL);

- (instancetype)initWithObserver:(id)observer;

- (void)refreshSection:(NSArray *)statusArray;

- (instancetype)initWithObserver:(id)observer loaded:(void (^)(NSArray *, BOOL))loaded;

- (instancetype)initWithLoaded:(void (^)(NSArray *, BOOL))loaded;

- (void)removeStatus:(CRStatus *)statuses;

- (void)reset;

- (void)removeObserver:(id)observer;

- (CRStatus *)status:(NSInteger)index;

- (NSInteger)statusCount;

- (void)update;

- (void)historyLoad;

- (void)load;
@end