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
#import "CRUserTimeLine.h"

@implementation CRUserTimeLine {
    NSString *_userId;
}

- (id)initWithLoadFinished:(LoadFinished)loadFinished userId:(NSString *)userId {
    self = [super initWithLoadFinished:loadFinished];
    if (self) {
        self.userId = userId;
    }

    return self;
}


- (NSString *)path {
    return @"statuses/user_timeline.json";
}

- (NSDictionary *)requestParams {
    [super requestParams];
    [_requestParams setObject:_userId forKey:@"user_id"];
    return _requestParams;
}

- (NSArray *)checkMute:(NSArray *)statusArray {
    return statusArray;
}

@end