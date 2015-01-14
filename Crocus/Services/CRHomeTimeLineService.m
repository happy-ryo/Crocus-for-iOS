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
#import "CRHomeTimeLineService.h"
#import "CRHomeTimeLine.h"


@implementation CRHomeTimeLineService {

}

- (instancetype)init {
    self = [super init];
    _semaphore = dispatch_semaphore_create(1);
    if (self) {
        __weak CRTimeLineService *weakSelf = self;
        self.publicTimeLine = [[CRHomeTimeLine alloc] initWithIncludeEntities:YES
                                                                 loadFinished:^(NSArray *statusArray, BOOL reload, NSError *error) {
                                                                     if (error == nil) {
                                                                         [weakSelf refreshSection:statusArray];
                                                                     } else {
                                                                         if (weakSelf.loaded) weakSelf.loaded(@[], YES);
                                                                     }
                                                                     dispatch_semaphore_signal(_semaphore);
                                                                 }];
    }

    return self;
}
@end