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

#import "CRFollowersList.h"

@implementation CRFollowersList {
    NSString *_idStr;
    NSMutableArray *_follower;
    NSString *_cursor;
    BOOL _stopLoading;
    didRetrieverFollowerList _function;
}

- (id)initWithIdStr:(NSString *)idStr function:(didRetrieverFollowerList)function {
    self = [super init];
    if (self) {
        _idStr = idStr;
        _function = function;
        _cursor = @"-1";
    }

    return self;
}


- (NSString *)path {
    return @"followers/list.json";
}

- (enum CR_REQUEST_METHOD)HTTPMethod {
    return GET;
}

- (NSDictionary *)requestParams {
    return @{@"user_id" : _idStr, @"cursor" : _cursor};
}

- (void)parseResponse:(NSData *)data error:(NSError *)error {
    [super parseResponse:data error:error];
    NSError *error1;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error1];
    NSString *cursor = [dictionary valueForKey:@"next_cursor_str"];
    if (![cursor isEqualToString:@"0"]) {
        _cursor = cursor;
        if (_stopLoading) {
            return;
        }
        [self load];
    }
    _function(YES, [dictionary valueForKey:@"users"]);
}

- (void)stopLoading {
    _stopLoading = YES;
}

@end
