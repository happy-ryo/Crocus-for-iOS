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
#import "CRTimeLineService.h"
#import "CRPublicTimeLine.h"
#import "CRStatus.h"


@interface CRTimeLineService ()
@property(nonatomic, strong) NSMutableArray *statuses;
@property(nonatomic, strong) NSArray *newerStatuses;
@property(nonatomic, strong) CRPublicTimeLine *publicTimeLine;
@end

@implementation CRTimeLineService {
    dispatch_semaphore_t _semaphore;

    void (^_loaded)(NSArray *array, BOOL reload);
}

- (instancetype)initWithObserver:(id)observer loaded:(void (^)(NSArray *array, BOOL reload))loaded {
    self = [self init];
    if (self) {
        self.statuses = @[].mutableCopy;
        _loaded = loaded;
        [self addObserver:observer];
    }
    return self;
}

- (instancetype)initWithLoaded:(void (^)(NSArray *array, BOOL))loaded {
    self = [self init];
    if (self) {
        _loaded = loaded;
        self.statuses = @[].mutableCopy;
    }

    return self;
}

- (instancetype)initWithObserver:(id)observer {
    self = [self init];
    if (self) {
        self.statuses = @[].mutableCopy;
        [self addObserver:observer];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    _semaphore = dispatch_semaphore_create(1);
    if (self) {
        __weak CRTimeLineService *weakSelf = self;
        _publicTimeLine = [[CRPublicTimeLine alloc] initWithIncludeEntities:YES
                                                               loadFinished:^(NSArray *statusArray, BOOL reload, NSError *error) {
                                                                   if (error == nil) {
                                                                       NSMutableArray *tmpStatusArray = @[].mutableCopy;
                                                                       for (NSDictionary *dictionary in statusArray) {
                                                                           CRStatus *status = [weakSelf parseStatus:dictionary];
                                                                           [tmpStatusArray addObject:status];
                                                                       }
                                                                       BOOL reloadFlg = weakSelf.publicTimeLine.sinceId == nil || weakSelf.statuses.count == 0;
                                                                       if (reloadFlg) {
                                                                           [weakSelf.statuses addObjectsFromArray:tmpStatusArray];
                                                                       } else {
                                                                           if (tmpStatusArray.count == 20) {
                                                                               weakSelf.statuses = tmpStatusArray.mutableCopy;
                                                                           } else {
                                                                               for (NSUInteger i = 0; tmpStatusArray.count > i; i++) {
                                                                                   [weakSelf.statuses insertObject:tmpStatusArray[i] atIndex:i];
                                                                               }
                                                                           }
                                                                       }
                                                                       if (_loaded) _loaded(tmpStatusArray, reloadFlg);
                                                                       weakSelf.newerStatuses = statusArray;
                                                                       dispatch_semaphore_signal(_semaphore);
                                                                   }
                                                               }];
    }

    return self;
}

- (void)addObserver:(id)observer {
    [self addObserver:observer forKeyPath:@"newerStatuses" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObserver:(id)observer {
    [self removeObserver:observer forKeyPath:@"newerStatuses"];
}

- (CRStatus *)status:(NSInteger)index {
    return self.statuses[(NSUInteger) index];
}

- (NSInteger)statusCount {
    return self.statuses.count;
}

- (void)update {
    dispatch_queue_t queueT = dispatch_queue_create("update", NULL);
    dispatch_async(queueT, ^{
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
        self.publicTimeLine.maxId = nil;
        CRStatus *lastStatus = [self status:0];
        self.publicTimeLine.sinceId = lastStatus.idStr;
        [self.publicTimeLine load];
    });
}

- (void)historyLoad {
    dispatch_queue_t queueT = dispatch_queue_create("historyLoad", NULL);
    dispatch_async(queueT, ^{
        dispatch_semaphore_wait(_semaphore, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC));
        self.publicTimeLine.sinceId = nil;
        CRStatus *maxStatus = [self status:self.statusCount - 1];
        self.publicTimeLine.maxId = maxStatus.idStr;
        [self.publicTimeLine load];
    });
}

- (void)load {
    dispatch_queue_t queueT = dispatch_queue_create("load", NULL);
    dispatch_async(queueT, ^{
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
        [self.publicTimeLine load];
    });
}
@end