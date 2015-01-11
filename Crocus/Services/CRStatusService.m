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
#import "CRStatusService.h"
#import "CRStatus.h"
#import "CRSpread.h"
#import "CRUpdate.h"


@implementation CRStatusService {
    CRStatus *_status;

}

- (instancetype)initWithStatus:(CRStatus *)status {
    self = [super init];
    if (self) {
        _status = status;
    }

    return self;
}

- (void)post:(NSString *)message callback:(void (^)(BOOL status, NSError *error))callBack {
    if (message.length == 0) {
        callBack(NO, [NSError errorWithDomain:@"crocus" code:500 userInfo:@{@"message" : @"投稿文が空です"}]);
    } else {
        CRUpdate *update = [[CRUpdate alloc] initWithStatus:message updateFinished:^(NSDictionary *dictionary, NSError *error) {
            if (error == nil) {
                callBack(YES, nil);
            } else {
                callBack(NO, error);
            }
        }];
        [update load];
    }
}

- (void)spread {
    CRSpread *spread = [[CRSpread alloc] initWithShowId:_status.idStr loadFinished:^(NSDictionary *statusDic, NSError *error) {

    }];
    [spread load];
}

- (void)reply {
    CRUpdate *crUpdate = [[CRUpdate alloc] initWithStatus:@"hoge" updateFinished:^(NSDictionary *dictionary, NSError *error) {

    }];
    [crUpdate load];
}
@end