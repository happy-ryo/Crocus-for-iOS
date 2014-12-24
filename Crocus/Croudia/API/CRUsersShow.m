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
#import "CRUsersShow.h"

@implementation CRUsersShow {
    NSString *_userId;
    GetFinished _getFinished;
}

- (id)initWithUserId:(NSString *)userId getFinished:(GetFinished)getFinished {
    self = [super init];
    if (self) {
        _userId = userId;
        _getFinished = getFinished;
    }

    return self;
}

- (NSString *)path {
    return @"users/show.json";
}

- (enum CR_REQUEST_METHOD)HTTPMethod {
    return GET;
}

- (NSDictionary *)requestParams {
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
    [mutableDictionary setObject:_userId forKey:@"user_id"];
    return mutableDictionary;
}

- (void)parseResponse:(NSData *)data error:(NSError *)error {
    [super parseResponse:data error:error];
    if (error) {
        return;
    }
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    if (_getFinished)_getFinished(dictionary, error);
}

@end